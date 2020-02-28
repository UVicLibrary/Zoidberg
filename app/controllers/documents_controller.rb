class DocumentsController < ApplicationController

  require 'mini_magick' # https://github.com/minimagick/minimagick
  require 'hexapdf' # https://github.com/gettalong/hexapdf
  require 'fileutils'

  before_action :set_document, only: [:show, :edit, :update, :destroy]

  # GET /documents
  # GET /documents.json
  def index
    @documents = Document.all.sort_by(&:created_at).reverse # Sort by reverse chronological order
  end

  # GET /documents/1
  # GET /documents/1.json
  def show

  end

  # GET /documents/new
  def new
    @document = Document.new
    @current_folder = File.join("/mnt","qdrive")
    @folders = Dir.entries(@current_folder).select {|entry| File.directory?(File.join(@current_folder, entry)) and !(entry =='.' || entry == '..') }.sort
  end

  def refresh_folder_picker
      if params[:expand_folder] == "parent" # Go up one level
        @current_folder = File.expand_path("..", params[:current_folder])
        @folders = get_subfolders(@current_folder)
      else # Go down one level
        @current_folder = File.join(params[:current_folder], params[:expand_folder])
        # List all the folders in the selected folder
        @folders = get_subfolders(@current_folder)
      end

      respond_to do |format|
        format.js {
          render partial: 'refresh_folder_picker'
        }
      end
  end

  def get_subfolders(folder)
    Dir.entries(folder).select {|entry| File.directory?(File.join(folder, entry)) and !(entry =='.' || entry == '..') }.sort
  end

  # GET /documents/1/edit
  def edit
  end

  # POST /documents
  # POST /documents.json
  def create
    warnings_list = []
    @document = Document.new(document_params)
    # if params[:document][:title].present?
      timestamp = "_#{DateTime.now.strftime("%s")}"
      if @document.title.include?(".pdf")
        @document.title = File.basename(params[:document][:title],".pdf")
      else
        @document.title = params[:document][:title]
      end
      if @document.title.include?(" ")
        spaces_warning = "There are spaces in the title. They will be converted to underscores in the file name. Continuing..."
        puts spaces_warning
        warnings_list.push(spaces_warning)
      end
    # else
      # @document.title = File.basename(params[:document][:original_filename], '.tif')
    # end
    # Pull from the mounted Q:Drive
    source_folder = @document.source_path
    unique_title = @document.title.gsub(' ','_') + timestamp
    # For displaying download
    @document.download_path = "/pdfs/#{snake_case(unique_title)}/#{unique_title}.pdf"

    # Check DPI of the first 5 TIFF files in the folder
    files = Dir.glob(File.join(source_folder, "*.tif"))[0...10]
    files.each do |filename|
      magick = MiniMagick::Image.open(filename)
      dpi = magick.resolution[0]
      if dpi < 600
        warnings_list.push(filename)
      end
    end

    # Generate warning messages and display them to user
    unless warnings_list.empty?
      if warnings_list.include?(spaces_warning)
        @warning_message = [spaces_warning]
        if warnings_list.length > 1
          @warning_message.push("These images are under 600 DPI: #{warnings_list[1...warnings_list.length].join(',')}. Continuing...")
        end
      elsif warnings_list.length > 1
        @warning_message = "These images are under 600 DPI: #{warnings_list.join(',')}. Continuing..."
      end
    end

    respond_to do |format|
      if @document.save
        format.html {
          flash[:success] = "Zoidberg is processing your files in the background and will email you when the PDF is done."
          if @warning_message.present?
            if @warning_message.count > 1
              flash[:warning] = @warning_message
            else
              flash[:warning] = @warning_message[0]
            end
          end

          redirect_to @document
          CreatePdfJob.perform_later(unique_title, source_folder, @document.id)

        }
        format.json { render :show, status: :created, location: @document }
      else
        format.html { render :new }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end


  end

  # PATCH/PUT /documents/1
  # PATCH/PUT /documents/1.json
  def update
    respond_to do |format|
      if @document.update(document_params)
        format.html { redirect_to @document, notice: 'Document was successfully updated.' }
        format.json { render :show, status: :ok, location: @document }
      else
        format.html { render :edit }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    @document.destroy
    respond_to do |format|
      format.html { redirect_to documents_url, notice: 'Document was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def snake_case(filename)
    filename.parameterize.underscore
  end

  private


    # Use callbacks to share common setup or constraints between actions.
    def set_document
      @document = Document.find(params[:id])
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def document_params
      params.require(:document).permit(:title, :download_path, :source_path, :email, {source_files: []})
    end

end
