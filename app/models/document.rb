class Document < ApplicationRecord
  belongs_to :profile

  # Allow document to read email attribute (passed in by documents/_form.html.erb)
  # without saving it to the model
  # attr_accessible :email

  def thumbnail_url
     "/pdfs/#{snake_case(self.title)}/#{self.title}_thumb.jpg"
  end

  def permalink
    "#{ENV['BASE_URL']}/pdfs/#{snake_case(self.title)}/#{self.title}.pdf"
  end

  def mnt_filepath
    self.source_path.gsub("\\","/").gsub('Q:','/mnt/qdrive')
  end

private

 def snake_case(str)
   str.parameterize.underscore
 end

end
