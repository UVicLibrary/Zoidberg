class DocumentsController < ApplicationController

  require 'mini_magick' # https://github.com/minimagick/minimagick
  require 'hexapdf' # https://github.com/gettalong/hexapdf
  require 'fileutils'
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
      if @document.title.include?(".pdf")
        @document.title = File.basename(params[:document][:title],".pdf")
      else
        @document.title = params[:document][:title]
      end
    else
      @document.title = File.basename(params[:document][:original_filename], '.tif')
    end
    # To Do: set profile ID based on the current session
    @document.profile_id = 5
    @document.source_path = params[:document][:source_path]
    # Pull from the mounted Q:Drive
    source_folder = @document.source_path.gsub("\\","/").gsub('Q:','/mnt/qdrive')
    # For writing to file
    download_path = "/home/tjychan/zoidberg/pdfs/#{snake_case(@document.title)}.pdf"
    # For displaying download to user
    @document.download_path = download_path

    respond_to do |format|
      if @document.save
        format.html { redirect_to @document, notice: 'Document was successfully created.' }
        format.json { render :show, status: :created, location: @document }
      else
        format.html { render :new }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end

    CreatePdfJob.perform_later(@document.title, source_folder)

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

    def resample_and_convert(filename, working_dir)
      # Check and print DPI of TIF image
      magick = MiniMagick::Image.open(filename)
      dpi = magick.resolution[0]
      case dpi
        when 600
          puts "Image is 600 DPI. Continuing..."
          tif_to_jpg(filename, working_dir)
        when 0..600
          puts "Warning: image is less than 600 DPI. Continuing..."
          tif_to_jpg(filename, working_dir)
        else
          puts "Image DPI is over 600. Resampling to 600 DPI..."
          MiniMagick::Tool::Magick::Convert.new do |convert|
            convert << filename
            convert.merge! ["-resample", "600"]
            path = convert << "#{working_dir}/#{File.basename(filename, ".tif")}.jpg"
          end
        path
        end
    end

    def tif_to_jpg(tif, working_dir)
      dest_path = "#{working_dir}/#{File.basename(tif, ".tif")}.jpg"
      MiniMagick::Tool::Magick::Convert.new do |convert|
        convert << tif
        convert.format "jpg"
        convert << dest_path
      end
      return dest_path
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_document
      @document = Document.find(params[:id])
    end

    def jpgs_to_pdf(profile_id, working_dir)
      puts "Converting to pdf"
      files = File.join(working_dir,"*.jpg")
      # Returns an array of every jpg file in working_dir, => ['../working/.../img001.jpg',...]
      jpg_array = Dir.glob(files).sort
      doc = HexaPDF::Document.new
      # Create a PDF document with images
      jpg_array.each do |jpg|
        image = doc.images.add(jpg)
        width = image.info.width
        height = image.info.height
        page = doc.pages.add([0, 0, width, height])
        page.canvas.image(image, at: [0,0], width: width, height: height)
      end
      doc.write("/home/tjychan/zoidberg/pdfs/combined.pdf") #optimize: true by default
      save_thumbnail(jpg_array.first, profile_id)
      # cleanup jpgs
      FileUtils.rm_rf(working_dir)
      # jpg_array.each do |jpg|
      #   File.delete(jpg)
      # end
    end

    def save_thumbnail(first_jpg, profile_id)
      thumbnail = MiniMagick::Image.open(first_jpg).resize "400x400"
      dest_dir = "/home/tjychan/zoidberg/public/uploads/documents/#{profile_id}"
      unless File.directory?(dest_dir) # Create a dir if it doesn't already exist
        FileUtils.mkdir_p(dest_dir)
      end
      path_to_thumb = "#{dest_dir}/thumb.jpg"
      thumbnail.write path_to_thumb
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def document_params
      params.require(:document).permit(:title, :download_path, :source_path, :profile_id, :thumbnail)
    end
end
