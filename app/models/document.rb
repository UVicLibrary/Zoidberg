class Document < ApplicationRecord
  belongs_to :profile

  # Allow document to read email attribute (passed in by documents/_form.html.erb)
  # without saving it to the model
  attr_accessible :email

  def thumbnail_url
     "/uploads/documents/#{self.profile_id}/thumb.jpg"
  end

  # For displaying file to user
  def download_url
    "/uploads/documents/#{self.profile_id}/#{self.download_path.split("/").last}"
  end

  def mnt_filepath
    self.source_path.gsub("\\","/").gsub('Q:','/mnt/qdrive')
  end

end
