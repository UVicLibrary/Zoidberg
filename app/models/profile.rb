class Profile < ApplicationRecord

  has_many :documents

  mount_uploader :sound, SoundUploader

end
