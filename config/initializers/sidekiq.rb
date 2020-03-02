Sidekiq.configure_server do |config|
  config.periodic do |mgr|
    # see any crontab reference for the first argument
    # e.g. http://www.adminschoice.com/crontab-quick-reference
    # or   https://crontab.guru/
    #
    # Delete tmp image files at 11:00pm every Sunday
    mgr.register('0 23 * * 0', "DeleteTmpFilesWorker")
  end
end