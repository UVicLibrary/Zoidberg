class AddDocumentsToProfile < ActiveRecord::Migration[5.2]
  def change
    add_reference :documents, :profile, foreign_key: true
  end
end
