# frozen_string_literal: true

source 'https://rubygems.org'

gem 'pg' # postgres adapter
gem 'rails', '~> 5.2.0'

gem 'm3', path: 'm3'
gem 'responders'

gem 'firesport', path: 'firesport'
gem 'firesport-series', path: 'firesport-series'

gem 'jquery-rails'
gem 'uglifier'
gem 'coffee-rails'
gem 'cocoon' # nested_form helper

gem 'active_model_serializers'

# charts
gem 'lazy_high_charts'

# ics export
gem 'icalendar'

# export
gem 'prawn-rails'
gem 'rqrcode'

# markdown
gem 'redcarpet'

# validation
gem 'schema_validations'
gem 'activerecord_views'

gem 'acts_as_list'
gem 'bcrypt'
gem 'bootsnap'
gem 'bootstrap-sass', '~> 3.0'
gem 'cancancan'
gem 'carrierwave'
gem 'draper', '~> 3.0'
gem 'haml-rails', '~> 1.0'
gem 'mini_magick', '~> 4.0'
gem 'puma'
gem 'remotipart', '~> 1.0'
gem 'sassc-rails'
gem 'simple_form', '~> 4.0'
gem 'turbolinks', '~> 5.0'
gem 'will_paginate-bootstrap', '~> 1.0'

# image optimazing
gem 'image_optim', '>= 0.28.0'
gem 'image_optim_pack'

# exports
gem 'caxlsx'
gem 'caxlsx_rails'
gem 'csv_builder', '~> 2.1.0'

# background jobs
gem 'daemons', '~> 1.2.0'
gem 'delayed_job_active_record', '~> 4.1.0'
gem 'whenever', '~> 0.9.0'

gem 'bootstrap3-datetimepicker-rails', '~> 4.17.37'
gem 'modernizr-rails', '~> 2.7.1'
gem 'momentjs-rails', '>= 2.9.0'
gem 'valid_email2'

group :production do
  gem 'unicorn'
  gem 'm3_log_file_parser', git: 'https://github.com/lichtbit/m3_log_file_parser.git'
end

group :development, :test do
  gem 'm3_rspec', path: 'm3_rspec'

  gem 'capybara', '>= 3.34.0'
  gem 'capybara-email'
  gem 'cuprite'
  gem 'database_cleaner-active_record'
  gem 'factory_bot_rails'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'launchy'
  gem 'phashion'
  gem 'pry'
  gem 'pry-byebug'
  gem 'rails-controller-testing'
  gem 'rspec-collection_matchers'
  gem 'rspec-rails'
  gem 'rspec-retry'
  gem 'rubocop'
  gem 'rubocop-daemon'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end

group :development do
  gem 'spring'

  gem 'm3_capistrano3', git: 'git@gitlab.lichtbit.com:lichtbit/m3_capistrano3.git'
  gem 'capistrano-rsync-plugin', git: 'https://github.com/Lichtbit/capistrano-rsync-plugin'
end

group :test do
  gem 'simplecov', require: false
end
