require 'hexapdf'

image_file = "img001.jpg"
doc = HexaPDF::Document.new

image = doc.images.add(image_file)
width = image.info.width
height = image.info.height
page = doc.pages.add([0, 0, width, height])
canvas = doc.pages[0].canvas
canvas.image(image, at: [0,0], width: width, height: height)
doc.write('hexa.pdf') #optimize: true by default
