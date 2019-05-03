require File.expand_path('boot', __dir__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FeuerwehrsportStatistik
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.action_controller.include_all_helpers = false

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Europe/Berlin'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :de

    config.autoload_paths += %W[#{config.root}/lib #{config.root}/app/models/concerns]

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.active_job.queue_adapter = :delayed_job
    config.caching = true

    # dynamic error handling
    config.exceptions_app = routes

    config.wettkampf_manager_path = Rails.root.join('spec', 'fixtures', 'wettkampf_manager')
    config.pdf2table_path = '/opt/pdf2table.jar'

    config.m3.session.login_redirect_url = { controller: '/backend/dashboards', action: :index }
    config.m3.compatible_version = '1.0.9'
  end
end
