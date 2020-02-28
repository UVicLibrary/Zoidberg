class DeleteDocumentWorker
  include Sidekiq::Worker

  # Delete the whole directory and destroy the document object
  def perform(download_path, document_id)
    to_delete = Rails.root.join("public", File.dirname(download_path)) # "/home/zoidberg/zoidberg/public/#{File.dirname(file_path)}"
    FileUtils.rm_rf(to_delete)
    Document.find(document_id).destroy
  end

end