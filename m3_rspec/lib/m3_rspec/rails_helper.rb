# frozen_string_literal: true

# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'
require 'spec_helper'
require 'rspec/collection_matchers'
require 'pry'
require 'factory_bot'
require 'database_cleaner/active_record'
require 'capybara/rspec'
require 'capybara/cuprite'
require 'capybara/email/rspec'
require 'webmock/rspec'
require 'vcr'
require 'timecop'
require 'phashion'
require 'rspec/retry'
require 'rails/controller/testing'

require 'm3_rspec'

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
factories_path = File.expand_path('factories', __dir__)

Dir["#{support_path}/**/*.rb"].sort.each { |f| require f }
Dir["#{factories_path}/**/*.rb"].sort.each { |f| require f }

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.ignore_localhost = true
  config.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  # factory girl
  config.include FactoryBot::Syntax::Methods

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.before(js: false) do
    Capybara.default_driver = :rack_test
  end

  config.after(js: false) do
    Capybara.default_driver = Capybara.javascript_driver
  end

  config.use_transactional_fixtures = false

  config.before(:suite) do
    if config.use_transactional_fixtures?
      raise(<<-MSG)
        Delete line `config.use_transactional_fixtures = true` from rails_helper.rb
        (or set it to false) to prevent uncommitted transactions being used in
        JavaScript-dependent specs.

        During testing, the app-under-test that the browser driver connects to
        uses a different database connection to the database connection used by
        the spec. The app's database connection would not be able to access
        uncommitted transaction data setup over the spec's database connection.
      MSG
    end

    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, type: :feature) do
    Timecop.freeze(Time.zone.local(2016, 2, 29, 12, 20, 42))

    # :rack_test driver's Rack app under test shares database connection
    # with the specs, so continue to use transaction strategy for speed.
    driver_shares_db_connection_with_specs = Capybara.current_driver == :rack_test

    unless driver_shares_db_connection_with_specs
      # Driver is probably for an external browser with an app
      # under test that does *not* share a database connection with the
      # specs, so use truncation strategy.
      DatabaseCleaner.strategy = :truncation
    end
  end

  config.after(:each, type: :feature) do
    Timecop.return
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end

  def mock_m3_login(login)
    patch_session = proc { |session, key|
      if key == M3::Login::Session::ID_KEY
        login.id
      elsif session.key?(key)
        session.fetch(key)
      end
    }
    allow_any_instance_of(ActionController::TestSession).to receive(:[], &patch_session)
    allow_any_instance_of(ActionDispatch::Request::Session).to receive(:[], &patch_session)
  end

  config.before(:each) do |example|
    @example = example
    @review_screenshot_number = 0
  end

  config.include M3Rspec::CapybaraHelper
  config.after(:suite) { M3Rspec::CapybaraHelper::Screenshots.m3_compare_and_open_screenshots }

  %i[controller view request].each do |type|
    config.include Rails::Controller::Testing::TestProcess, type: type
    config.include Rails::Controller::Testing::TemplateAssertions, type: type
    config.include Rails::Controller::Testing::Integration, type: type
  end
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
  config.default_driver = config.javascript_driver
end
Capybara.server = :puma, { Silent: true }
