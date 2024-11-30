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

# HACK: for rack 3
unless Rails.env.local?
  class Unicorn::HttpServer
    # writes the rack_response to socket as an HTTP response
    def http_response_write(socket, status, headers, body,
                            req = Unicorn::HttpRequest.new)
      hijack = nil

      if headers
        code = status.to_i
        msg = STATUS_CODES[code]
        start = req.response_start_sent ? '' : 'HTTP/1.1 '
        buf = "#{start}#{msg ? %(#{code} #{msg}) : status}\r\n" \
              "Date: #{httpdate}\r\n" \
              "Connection: close\r\n"
        headers.each do |key, value|
          case key
          when /\A(?:Date|Connection)\z/i
            next
          when 'rack.hijack'
            # This should only be hit under Rack >= 1.5, as this was an illegal
            # key in Rack < 1.5
            hijack = value
          else
            case value
            when Array # Rack 3
              value.each { |v| buf << "#{key}: #{v}\r\n" }
            when /\n/ # Rack 2
              # avoiding blank, key-only cookies with /\n+/
              value.split(/\n+/).each { |v| buf << "#{key}: #{v}\r\n" }
            else
              buf << "#{key}: #{value}\r\n"
            end
          end
        end
        socket.write(buf << "\r\n")
      end

      if hijack
        req.hijacked!
        hijack.call(socket)
      else
        body.each { |chunk| socket.write(chunk) }
      end
    end
  end
end
