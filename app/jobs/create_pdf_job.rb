class CreatePdfJob < ApplicationJob
  queue_as :default


  # title is a string with the document name
  # source_folder is a path to folder on Q:Drive
  def perform(title, source_folder, document_id)
    working_dir = FileUtils.mkdir_p("/home/tjychan/zoidberg/working/#{snake_case(source_folder.split('/').last)}").first
    dest_file = Rails.root.join("public", "pdfs", "#{snake_case(title)}", "#{title}.pdf" )  # "/mnt/qdrive/LSYS/vol02/Testing/PDF/""

    Dir.foreach(source_folder) do |src_file|
      next if src_file == '.' or src_file == '..' # Dir.foreach includes these "file names" but we don't want them
      if src_file.include? ".tif" #take .tif or .tiff
        puts resample_and_convert("#{source_folder}/#{src_file}", working_dir)
      else
        # To do: way to print this to the user. Include in documents#create instead?
        puts "Warning: #{src_file} is not a tif file. Skipping..."
      end
    end

    jpgs_to_pdf(title, working_dir)
    combined_pdf = "#{working_dir}/combined.pdf"
    # Linearize pdf and make it web-ready
    `qpdf #{combined_pdf} --linearize #{dest_file}`
    # Delete the working pdf document
    FileUtils.rm_rf(working_dir)
    puts "#{title}.pdf is ready"
    # Change document to completed
    document = Document.find(document_id)
    document.completed = true
    document.save
    PdfCreatedMailer.with(host: ENV['BASE_URL'], document: document).pdf_ready.deliver
  end

  def snake_case(filename)
    filename.parameterize.underscore
  end

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

  def jpgs_to_pdf(title, working_dir)
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
    doc.write("#{working_dir}/combined.pdf") #optimize: true by default
    save_thumbnail(title, jpg_array.first)
    # cleanup jpgs
    # jpg_array.each do |jpg|
    #   File.delete(jpg)
    # end
  end

  def save_thumbnail(title, first_jpg)
    thumbnail = MiniMagick::Image.open(first_jpg).resize "400x400"
    dest_dir = Rails.root.join("public", "pdfs", "#{snake_case(title)}") # "/mnt/qdrive/LSYS/vol02/Testing/PDF/"
    unless File.directory?(dest_dir)
      dest_dir.mkdir
    end
    path_to_thumb = "#{dest_dir}/#{title}_thumb.jpg"
    thumbnail.write path_to_thumb
  end


end
