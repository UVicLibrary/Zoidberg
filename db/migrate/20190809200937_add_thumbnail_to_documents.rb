class AddThumbnailToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :thumbnail, :string
  end
end
