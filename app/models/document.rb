class Document < ApplicationRecord
  belongs_to :profile

  validates :email, presence: true
  validates :title, uniqueness: true

  mount_uploaders :source_files, SourceFilesUploader
  serialize :source_files, JSON

  def thumbnail_url
     "/pdfs/#{snake_case(self.title)}/#{self.title.gsub(' ','_')}_thumb.jpg"
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
