class DeleteTmpFilesWorker
  include Sidekiq::Worker

  def perform(*args)
    tmp_files = Dir.glob(["/home/zoidberg/zoidberg/tmp/*.jpg", "/home/zoidberg/zoidberg/tmp/*.tif"])
    tmp_files.each { |f| File.delete(f) }
  end

end