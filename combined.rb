require 'mini_magick' # https://github.com/minimagick/minimagick
require 'hexapdf' # https://github.com/gettalong/hexapdf
require 'byebug'

def tif_to_jpg(tif)
  MiniMagick::Tool::Magick::Convert.new do |convert|
    convert << tif
    convert.format "jpg"
    convert << "working/#{File.basename(tif, ".tif")}.jpg"
  end
  return "working/#{File.basename(tif, ".tif")}.jpg"
end

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
        convert << "working/#{File.basename(filename, ".tif")}.jpg"
      end
    "working/#{File.basename(filename, ".tif")}.jpg"
    end
end

def jpgs_to_pdf
  puts "Converting to pdf"
  files = File.join("**","working","**","*.jpg")
  # Returns an array of every jpg file in working, => ['working/img001.jpg'...]
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
  doc.write("pdfs/combined.pdf") #optimize: true by default
end


folder = 'tif_bunch'
Dir.foreach(folder) do |src_file|
  next if src_file == '.' or src_file == '..' # Dir.foreach gives us these "file names" but we don't want them
  if src_file.include? ".tif" #take .tif or .tiff
    puts resample_and_convert("#{folder}/#{src_file}")
  else
    puts "Warning: #{src_file} is not a tif file. Skipping..."
  end
end
jpgs_to_pdf
combined_pdf = "pdfs/combined.pdf"
# # Linearize pdf and make it web-ready
pdf_name = "final"
`qpdf #{combined_pdf} --linearize pdfs/#{pdf_name}.pdf`
# Delete the working pdf document
File.delete(combined_pdf)
puts "#{pdf_name}.pdf is ready"
