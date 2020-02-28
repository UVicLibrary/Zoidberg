class CreateDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :documents do |t|
      t.text :title
      t.text :download_path
      t.text :source_path
      t.text :thumbnail_path

      t.timestamps
    end
  end
end
