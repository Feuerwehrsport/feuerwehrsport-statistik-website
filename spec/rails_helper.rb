# This file is copied to spec/ when you run 'rails generate m3:rspec:install'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

require 'spec_helper'
require 'm3_rspec/rails_helper'
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
Dir[Rails.root.join('spec/factories/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.before(type: :controller) do
    create(:m3_website, domain: 'test.host')
  end
  config.before(type: :feature) do
    create(:m3_website, domain: '127.0.0.1')
  end

  config.fixture_path = "#{::Rails.root}/spec/fixtures"
end
