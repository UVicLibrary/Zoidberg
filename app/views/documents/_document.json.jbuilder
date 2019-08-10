json.extract! document, :id, :title, :download_path, :source_path, :thumbnail_path, :profile_id, :created_at, :updated_at
json.url document_url(document, format: :json)
