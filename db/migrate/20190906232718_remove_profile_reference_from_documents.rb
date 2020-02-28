class RemoveProfileReferenceFromDocuments < ActiveRecord::Migration[5.2]
  def change
    remove_reference :documents, :profile, index: true, foreign_key: true
  end
end
