# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FeuerwehrsportStatistik
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

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

    config.active_job.queue_adapter = :delayed_job
    config.caching = true

    # dynamic error handling
    config.exceptions_app = routes

    Rails.application.config.active_record.belongs_to_required_by_default = false

    config.m3.session.login_redirect_url = { controller: '/backend/dashboards', action: :index }

    config.after_initialize do
      Rails.application.precompiled_assets if config.assets.compile
    end

    config.action_mailer.default_options = { from: 'Feuerwehrsport-Statistik <automailer@feuerwehrsport-statistik.de>' }
    config.action_mailer.delivery_method = :file

    config.generators do |g|
      g.orm             :active_record
      g.template_engine :haml
      g.test_framework  :rspec, fixture: false
      g.view_specs      false
      g.helper_specs    false
    end
  end
end
