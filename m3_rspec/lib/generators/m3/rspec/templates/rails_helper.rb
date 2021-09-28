# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate m3:rspec:install'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)

require 'spec_helper'
require 'm3_rspec/rails_helper'
Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }
Dir[Rails.root.join('spec/factories/**/*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
end
