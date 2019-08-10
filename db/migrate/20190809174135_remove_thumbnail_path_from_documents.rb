class RemoveThumbnailPathFromDocuments < ActiveRecord::Migration[5.2]
  def change
    remove_column :documents, :thumbnail_path, :text
  end
end
