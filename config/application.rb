require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Zoidberg # Digiscript
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    config.cache_store = :file_store, "/mnt/sdb/tmp"

    config.action_mailer.default_url_options = { host: ENV['BASE_URL'] }

    config.active_job.queue_adapter = :sidekiq

    config.enable_dependency_loading = true
    config.autoload_paths << Rails.root.join('lib')

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
