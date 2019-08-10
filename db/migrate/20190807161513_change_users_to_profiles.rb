class ChangeUsersToProfiles < ActiveRecord::Migration[5.2]
  def change
    rename_table :users, :profiles
  end
end
