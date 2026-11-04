# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '~> 8.1.4'

gem 'pg' # postgres adapter
gem 'puma' # webserver
gem 'bcrypt' # password hashs

gem 'sprockets-rails' # asset pipeline
gem 'cancancan' # abilities
gem 'carrierwave', '> 3.0.0' # uploads
gem 'mini_magick' # image processing
gem 'simple_form' # more form support
gem 'm3', path: 'm3' # old lichtbit stuff

gem 'bootsnap', require: false # Reduces boot times through caching; required in config/boot.rb
gem 'rails_log_parser' # to analyise log

gem 'solid_queue' # background jobs
gem 'mission_control-jobs' # control page for background jobs

# # templating
gem 'haml-rails' # haml templating

# gem 'firesport', path: 'firesport'
# gem 'firesport-series', path: 'firesport-series'

# assets
gem 'jquery-rails' # jquery js
gem 'terser' # asset compressor
gem 'coffee-rails' # coffee script
gem 'image_optim' # image optimazing
gem 'image_optim_pack' # image optimazing binaries
gem 'bootstrap-sass' # bootstrap with sass support
gem 'sassc-rails' # sass for rails
gem 'will_paginate' # pagination

# exports
gem 'prawn-rails' # pdf export
gem 'caxlsx_rails' # xlsx exports
gem 'draper' # model decorators

# validation
gem 'activerecord_views' # save db views in code
gem 'generated_schema_validations' # validate models by schema
gem 'valid_email2' # validate emails

group :development, :test do
  gem 'debug' # debugger

  # code beautifier
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'rubocop-rspec_rails'
  gem 'rubocop-factory_bot'
  gem 'rubocop-capybara'
end

group :development do
  gem 'web-console'

  gem 'capistrano3_featureset' # Deployment
end

group :test do
  gem 'rspec-rails' # rspec for rails
  gem 'simplecov', require: false # test coverage
  gem 'webmock' # mock http requests
  gem 'cuprite' # headless chrome driver for capybara
  gem 'guard', require: false # on demand tests
  gem 'guard-rspec', require: false # on demand tests
  gem 'factory_bot_rails' # factories for models
  gem 'capybara' # feature test helper
end
