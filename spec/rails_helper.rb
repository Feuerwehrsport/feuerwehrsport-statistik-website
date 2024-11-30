# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate m3:rspec:install'
require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)

require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/cuprite'

# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?

ActiveRecord::Migration.maintain_test_schema!

# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

support_path = File.expand_path('support', __dir__)
Dir["#{support_path}/**/*.rb"].each { |f| require f }

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.ignore_localhost = true
  config.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.infer_spec_type_from_file_location!
  config.fixture_paths = [Rails.root.join('spec/fixtures')]
  config.before(:each, type: :request) { host! 'test.host' }

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!

  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # factory bot
  config.include FactoryBot::Syntax::Methods

  config.before(js: false) { Capybara.default_driver = :rack_test }
  config.after(js: false)  { Capybara.default_driver = Capybara.javascript_driver }

  config.before(:suite) { DatabaseCleaner.clean_with(:truncation) }
  config.before { DatabaseCleaner.strategy = :transaction }

  config.before(:each, type: :feature) do
    Timecop.freeze(Time.zone.local(2016, 2, 29, 12, 20, 42))

    driver_shares_db_connection_with_specs = Capybara.current_driver == :rack_test
    DatabaseCleaner.strategy = :truncation unless driver_shares_db_connection_with_specs
  end
  config.after(:each, type: :feature) { Timecop.return }

  config.before       { DatabaseCleaner.start }
  config.append_after { DatabaseCleaner.clean }
  config.before { SingleDiscipline.instance_variable_set(:@single_disciplines, nil) }

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

  ActiveJob::Base.queue_adapter = :test
end

Capybara.register_driver(:cuprite) do |app|
  options = {
    window_size: [1280, 1024],
    extensions: ["#{support_path}/phantomjs_disable_animations.js"],
  }
  options[:browser_options] = { 'no-sandbox': nil } if ENV['CI_SERVER'].present?

  Capybara::Cuprite::Driver.new(app, options)
end

Capybara.configure do |config|
  config.app_host = 'http://127.0.0.1:7787'
  config.default_host = 'http://127.0.0.1'
  config.run_server = true
  config.server_port = 7787
  config.javascript_driver = :cuprite
  config.disable_animation = true
  config.default_driver = config.javascript_driver
end
Capybara.server = :puma, { Silent: true }
