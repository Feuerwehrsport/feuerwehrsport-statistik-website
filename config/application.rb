# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
# require "active_storage/engine" # uploads use carrierwave
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
    config.load_defaults 8.1

    config.action_controller.include_all_helpers = false
    config.time_zone = 'Europe/Berlin'
    config.i18n.default_locale = :de

    config.active_job.queue_adapter = :solid_queue
    config.solid_queue.shutdown_timeout = 30.seconds
    config.solid_queue.default_concurrency_control_period = 2.hours

    config.active_record.belongs_to_required_by_default = false

    config.x.email_validation = { mx: true }
    # anonymous login (ApiUser): store for challenges and rate limits, minimum seconds to answer the question
    config.x.api_login_store = ActiveSupport::Cache::FileStore.new(Rails.root.join('tmp/cache/api_login'))
    config.x.api_login_min_seconds = 3
    # tokens for Feusport to transfer import requests (comma separated to allow rotation)
    config.x.feusport_import_tokens = ENV.fetch('FEUSPORT_IMPORT_TOKENS', '').split(',').map(&:strip).compact_blank
    config.caching = true

    # dynamic error handling
    config.exceptions_app = routes

    config.mission_control.jobs.http_basic_auth_enabled = false
    config.mission_control.jobs.base_controller_class = 'AdminController'
    config.debug_email_address = 'georf@georf.de'

    config.default_url_options = {}

    # data-disable-with was evaluated by jquery_ujs only (Turbo forms disable their submitter themselves)
    config.action_view.automatically_disable_submit_tag = false
    config.action_mailer.default_options = { from: 'Feuerwehrsport-Statistik <automailer@feuerwehrsport-statistik.de>' }

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
