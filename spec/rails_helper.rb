# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate m3:rspec:install'
require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)

require 'spec_helper'
require 'm3_rspec/rails_helper'
Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }
# Dir[Rails.root.join('spec/factories/**/*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  config.fixture_path = Rails.root.join('spec/fixtures')

  Capybara.disable_animation = true
  config.before(type: :feature) do
    Capybara.current_session # start capybara and puma before feature spec
    Capybara.disable_animation = true
    Rails.configuration.default_url_options[:host] = '127.0.0.1'
    Rails.configuration.default_url_options[:port] = 7787
  end
  config.after(type: :feature) do
    Rails.configuration.default_url_options[:host] = 'test.host'
    Rails.configuration.default_url_options[:port] = 80
  end
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(
    app,
    window_size: [1280, 1024],
    phantomjs_options: ['--debug=no', '--load-images=yes', '--ignore-ssl-errors=yes',
                        '--ssl-protocol=TLSv1'],
    debug: false,
    extensions: [Rails.root.join('m3_rspec/lib/m3_rspec/support/phantomjs_disable_animations.js').to_s],
  )
end

Capybara.configure do |config|
  config.server = :webrick
end
