# frozen_string_literal: true

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

require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

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

  # system specs run in headless Chrome (Cuprite)
  config.before(type: :system) do
    browser_options = ENV['CI_SERVER'].present? ? { 'no-sandbox': nil } : {}
    # process_timeout: Chrome sometimes starts slowly on CI runners; js_errors: JavaScript errors fail the spec
    driven_by :cuprite, screen_size: [1280, 1024], options: { process_timeout: 30, browser_options:, js_errors: true }
  end

  # every example runs in a transaction; the in-process server of system specs shares the connection
  config.use_transactional_fixtures = true
  # activerecord_views creates the SQL views when a model class is loaded. Load all models before the suite and
  # (re)create missing views: with eager loading (CI=1) the classes are loaded before maintain_test_schema! may
  # reload the test database, which drops the views again.
  config.before(:suite) do
    Rails.autoloaders.main.eager_load_dir(Rails.root.join('app/models').to_s)
    ActiveRecordViews.registered_views.each(&:reload!)
  end
  config.include ActiveSupport::Testing::TimeHelpers
  config.before { ActionController::Base.cache_store.clear }
  config.before { Current.reset } # per request values, like a new request
  # challenges and rate limits of the anonymous login
  config.before { Rails.configuration.x.api_login_store.clear }
  # also for specs without rails type (e.g. spec/renderers)
  config.after { travel_back } # rubocop:disable Rails/RedundantTravelBack

  config.before(:each, type: :system) { travel_to(Time.zone.local(2016, 2, 29, 12, 20, 42)) }
  config.before { SingleDiscipline.instance_variable_set(:@single_disciplines, nil) }

  config.before(type: :system) do
    Capybara.current_session # start capybara and puma before system spec
    Rails.configuration.default_url_options[:host] = '127.0.0.1'
    Rails.configuration.default_url_options[:port] = 7787
  end
  config.after(type: :system) do
    Rails.configuration.default_url_options[:host] = 'test.host'
    Rails.configuration.default_url_options[:port] = 80
  end

  ActiveJob::Base.queue_adapter = :test
end

Capybara.configure do |config|
  config.app_host = 'http://127.0.0.1:7787'
  config.default_host = 'http://127.0.0.1'
  config.run_server = true
  config.server_port = 7787
  config.disable_animation = true
end
Capybara.server = :puma, { Silent: true }
