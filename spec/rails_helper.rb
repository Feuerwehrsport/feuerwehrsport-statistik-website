# This file is copied to spec/ when you run 'rails generate m3:rspec:install'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)

require 'spec_helper'
require 'm3_rspec/rails_helper'
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
Dir[Rails.root.join('spec/factories/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.before(type: :feature) do
    domain = Capybara.default_host.gsub(%r{^https?://}, '')
    website = M3::Website.create_with(key: :allos_media, domain: domain, title: 'Allos - Mediendatenbank',
                                      default_site: true, port: 3000).find_or_create_by!(name: 'Kranbauer Webpräsenz')
    website.delivery_setting.update!(website: website, delivery_method: :test, from_address: "no-reply@#{domain}")
  end

  config.before(type: :controller) do
    create(:m3_website, domain: 'test.host')
  end

  config.fixture_path = "#{::Rails.root}/spec/fixtures"
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app,
                                    window_size: [1280, 1024],
                                    phantomjs_options: ['--debug=no', '--load-images=yes', '--ignore-ssl-errors=yes',
                                                        '--ssl-protocol=TLSv1'],
                                    debug: false,
                                    extensions: ['m3_rspec/lib/m3_rspec/support/phantomjs_disable_animations.js'])
end

Capybara.configure do |config|
  config.app_host = 'http://127.0.0.1:7787'
  config.default_host = 'http://127.0.0.1'
  config.run_server = true
  config.server_port = 7787
  config.javascript_driver = :poltergeist
  config.default_driver = config.javascript_driver
  config.server = :webrick
end
