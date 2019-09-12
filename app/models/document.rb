class Document < ApplicationRecord

  validates :email, presence: true, format: { # Contains @uvic.ca
    with: /.+(@uvic.ca)/, message: "must be a valid @uvic.ca address"
  }
  validates :source_path, presence: true, if: :has_tifs?
  validates :title, format: {
    with: /\A[^"']+\z/, message: "can't contain quotation marks"
  }

  # Check if it has tifs
  def has_tifs?
    if Dir.glob(File.join(self.source_path, "*.tif")).empty?
      errors.add(:base, "The selected folder must have TIF files in it")
    end
  end

  def thumbnail_url
     "/pdfs/#{snake_case(self.download_path.split("/")[-2])}/#{File.basename(self.download_path.split("/")[-1], ".pdf")}_thumb.jpg"
  end

  def permalink
    "#{ENV['BASE_URL']}/pdfs/#{snake_case(self.title)}/#{self.title}.pdf"
  end

  def qdrive_filepath
    self.source_path.gsub('/mnt/qdrive','Q:').gsub("/","\\")
  end

private

 def snake_case(str)
   str.parameterize.underscore
 end

end
