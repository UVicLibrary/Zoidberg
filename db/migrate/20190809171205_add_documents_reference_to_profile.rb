class AddDocumentsReferenceToProfile < ActiveRecord::Migration[5.2]
  def change
    add_reference :profiles, :document, index: true
  end
end
