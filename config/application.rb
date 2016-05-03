require File.expand_path('../boot', __FILE__)

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

    config.autoload_paths += %W(#{config.root}/lib #{config.root}/app/models/concerns)

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.active_record.schema_format = :sql
    config.active_job.queue_adapter = :delayed_job
    config.base_url = "http://localhost:5060"
    config.caching = true

    # dynamic error handling
    config.exceptions_app = self.routes

    config.wettkampf_manager_path = "#{Rails.root}/spec/fixtures/wettkampf_manager"

    # action_mailer
    config.action_mailer.default_options = {
      from: "automailer@feuerwehrsport-statistik.de"
    }
    config.action_mailer.smtp_settings = {
      address: 'www.feuerwehrsport-statistik.de',
      port: 465,
      user_name: ENV["EMAIL_USERNAME"],
      password: ENV["EMAIL_PASSWORD"],
      tls: true,
      smtp_sender: "automailer@feuerwehrsport-statistik.de",
      openssl_verify_mode: OpenSSL::SSL::VERIFY_NONE,
    }

    logdir_path = "/srv/fws-statistik/shared/log"
    config.log_file_parser = OpenStruct.new(
      run_before: -> { `cd "#{logdir_path}" ; find -name "production.log-*" ! -name "*.gz" -exec ln -sf {} production.yesterday \;` },
      log_path: "#{logdir_path}/production.yesterday",
    )
  end
end
