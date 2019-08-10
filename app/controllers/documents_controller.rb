class DocumentsController < ApplicationController

  require 'mini_magick' # https://github.com/minimagick/minimagick
  require 'hexapdf' # https://github.com/gettalong/hexapdf
  require 'byebug'

  before_action :set_document, only: [:show, :edit, :update, :destroy]

  # GET /documents
  # GET /documents.json
  def index
    @documents = Document.all
  end

  # GET /documents/1
  # GET /documents/1.json
  def show
  end

  # GET /documents/new
  def new
    @document = Document.new
  end

  # GET /documents/1/edit
  def edit
  end

  # POST /documents
  # POST /documents.json
  def create
    @document = Document.new(document_params)
    if params[:document][:title].present?
      @document.title = params[:document][:title]
    else
      @document.title = File.basename(params[:document][:original_filename], '.tif')
    end
    # To Do: set profile ID based on the current session
    @document.profile_id = 5
    source_folder = params[:document][:source_path].gsub("\\","/").gsub('Q:','/mnt/qdrive')
    @document.source_path = source_folder

    # Substitute for file on mounted qdrive with Linux file paths
    Dir.foreach(source_folder) do |src_file|
      next if src_file == '.' or src_file == '..' # Dir.foreach gives us these "file names" but we don't want them
      if src_file.include? ".tif" #take .tif or .tiff
        puts resample_and_convert("#{source_folder}/#{src_file}")
      else
        puts "Warning: #{src_file} is not a tif file. Skipping..."
      end
    end
    jpgs_to_pdf
    combined_pdf = "/home/tjychan/zoidberg/pdfs/combined.pdf"
    # Linearize pdf and make it web-ready
    pdf_name = "final"
    `qpdf #{combined_pdf} --linearize pdfs/#{pdf_name}.pdf`
    # Delete the working pdf document
    File.delete(combined_pdf)
    puts "#{pdf_name}.pdf is ready"

    respond_to do |format|
      if @document.save
        format.html { redirect_to @document, notice: 'Document was successfully created.' }
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

  private

    def resample_and_convert(filename)
      # Check and print DPI of TIF image
      magick = MiniMagick::Image.open(filename)
      dpi = magick.resolution[0]
      case dpi
        when 600
          puts "Image is 600 DPI. Continuing..."
          tif_to_jpg(filename)
        when 0..600
          puts "Warning: image is less than 600 DPI. Continuing..."
          tif_to_jpg(filename)
        else
          puts "Image DPI is over 600. Resampling to 600 DPI..."
          MiniMagick::Tool::Magick::Convert.new do |convert|
            convert << filename
            convert.merge! ["-resample", "600"]
            path = convert << "/home/tjychan/zoidberg/working/#{File.basename(filename, ".tif")}.jpg"
          end
        path
        end
    end

    def tif_to_jpg(tif)
      MiniMagick::Tool::Magick::Convert.new do |convert|
        convert << tif
        convert.format "jpg"
        convert << "/home/tjychan/zoidberg/working/#{File.basename(tif, ".tif")}.jpg"
      end
      return "/home/tjychan/zoidberg/working/#{File.basename(tif, ".tif")}.jpg"
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_document
      @document = Document.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def document_params
      params.require(:document).permit(:title, :download_path, :source_path, :profile_id, :thumbnail)
    end
end
