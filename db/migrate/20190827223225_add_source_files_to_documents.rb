class AddSourceFilesToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :source_files, :string
  end
end
