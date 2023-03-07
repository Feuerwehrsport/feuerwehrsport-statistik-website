# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '~> 5.2.0'
gem 'pg' # postgres adapter
gem 'bcrypt' # password hashs
gem 'cancancan' # abilities

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
gem 'bootsnap'
gem 'bootstrap-sass', '~> 3.0'
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

gem 'caxlsx_rails' # xlsx exports
gem 'daemons' # background jobs
gem 'delayed_job_active_record' # background jobs
gem 'whenever' # cronjobs

gem 'valid_email2' # validate emails

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
  gem 'vcr'
  gem 'webmock'

  # code beautifier
  gem 'rubocop'
  gem 'rubocop-daemon'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end

group :development do
  gem 'spring'

  gem 'm3_capistrano3', git: 'git@gitlab.lichtbit.com:lichtbit/m3_capistrano3.git'
  gem 'capistrano-rsync-plugin', git: 'https://github.com/Lichtbit/capistrano-rsync-plugin'
end

group :test do
  gem 'simplecov', require: false # test coverage
  gem 'timecop' # hold specific time
end
