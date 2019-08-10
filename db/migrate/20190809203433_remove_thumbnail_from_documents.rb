class RemoveThumbnailFromDocuments < ActiveRecord::Migration[5.2]
  def change
    remove_column :documents, :thumbnail, :string
  end
end
