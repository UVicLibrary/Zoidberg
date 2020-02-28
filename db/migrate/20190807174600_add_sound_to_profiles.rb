class AddSoundToProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :sound, :string
  end
end
