# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '~> 7.0.0'

# background stuff
gem 'pg' # postgres adapter
gem 'bcrypt' # password hashs
gem 'bootsnap', require: false # boot rails faster
gem 'daemons' # background jobs
gem 'delayed_job_active_record' # background jobs
gem 'whenever' # cronjobs
gem 'puma' # dev web server
gem 'cancancan' # abilities
gem 'carrierwave' # uploads
gem 'mini_magick' # image processing
gem 'responders' # set of responders
gem 'simple_form' # more form support
gem 'm3', path: 'm3' # old lichtbit stuff
gem 'sprockets-rails' # sprockets for rails
gem 'matrix'
gem 'acts_as_list' # position of models

# templating
gem 'haml-rails' # haml templating
gem 'redcarpet' # markdown

gem 'firesport', path: 'firesport'
gem 'firesport-series', path: 'firesport-series'

# assets
gem 'jquery-rails' # jquery js
gem 'terser' # asset compressor
gem 'coffee-rails' # coffee script
gem 'cocoon' # nested_form helper
gem 'lazy_high_charts' # charts
gem 'image_optim' # image optimazing
gem 'image_optim_pack' # image optimazing binaries
gem 'bootstrap-sass' # bootstrap with sass support
gem 'sassc-rails' # sass for rails
gem 'turbo-rails' # hot wire links
gem 'will_paginate-bootstrap' # pagination with bootstrap layout

# exports
gem 'icalendar' # ics export
gem 'active_model_serializers' # model serializer
gem 'prawn-rails' # pdf export
gem 'rqrcode' # pdf/png qr code
gem 'caxlsx_rails' # xlsx exports
gem 'draper' # model decorators

# validation
gem 'schema_validations' # validations from database
gem 'activerecord_views' # save db views in code
gem 'valid_email2' # validate emails

group :production do
  gem 'unicorn'
  gem 'rails_log_parser'
end

group :development, :test do
  gem 'pry' # debugger
  gem 'pry-byebug' # debugger

  # code beautifier
  gem 'rubocop'
  gem 'rubocop-daemon'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end

group :development do
  gem 'spring'

  gem 'web-console'
  gem 'm3_capistrano3', git: 'git@gitlab.lichtbit.com:lichtbit/m3_capistrano3.git'
  gem 'capistrano-rsync-plugin', git: 'https://github.com/Lichtbit/capistrano-rsync-plugin'
end

group :test do
  gem 'rspec-rails' # rspec for rails
  gem 'simplecov', require: false # test coverage
  gem 'timecop' # hold specific time
  gem 'vcr' # record http requests
  gem 'webmock' # mock http requests
  gem 'cuprite' # headless chrome driver for capybara
  gem 'guard', require: false # on demand tests
  gem 'guard-rspec', require: false # on demand tests
  gem 'factory_bot_rails' # factories for models
  gem 'database_cleaner-active_record' # cleaning strategies for specs
  gem 'capybara' # feature test helper
end
