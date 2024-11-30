# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require "action_mailbox/engine"
# require "action_text/engine"
require 'action_view/railtie'
# require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FeuerwehrsportStatistik
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    config.action_controller.include_all_helpers = false
    config.time_zone = 'Europe/Berlin'
    config.i18n.default_locale = :de

    config.active_job.queue_adapter = :delayed_job

    config.active_record.belongs_to_required_by_default = false

    config.x.email_validation = { mx: true }
    config.caching = true

    # dynamic error handling
    config.exceptions_app = routes

    config.default_url_options = {}
    config.action_mailer.default_options = { from: 'Feuerwehrsport-Statistik <automailer@feuerwehrsport-statistik.de>' }

    config.m3.session.login_redirect_url = { controller: '/backend/dashboards', action: :index }

    config.after_initialize do
      Rails.application.precompiled_assets if config.assets.compile
    end

    config.action_mailer.delivery_method = :file

    config.generators do |g|
      g.orm             :active_record, primary_key_type: :uuid
      g.system_tests    nil
      g.template_engine :haml
      g.test_framework  :rspec,
                        controller_specs: false,
                        fixtures: false,
                        routing_specs: false,
                        view_specs: false
      g.view_specs      false
      g.assets          false
      g.helper          false
      g.helper_specs    false
    end
  end
end
