class Document < ApplicationRecord
  belongs_to :profile

  # mount_uploader :thumbnail, ThumbnailUploader

end
