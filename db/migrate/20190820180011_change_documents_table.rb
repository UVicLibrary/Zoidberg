class ChangeDocumentsTable < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :email, :string
    add_column :documents, :completed, :boolean, default: false
  end
end
