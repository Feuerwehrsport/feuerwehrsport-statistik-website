source 'https://rubygems.org'

gem 'rails', '~> 4'

# this version works with rails 4.2.3
gem 'mysql2', '~> 0.3.18'
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5'
gem 'jquery-rails'
gem 'bootstrap-sass'
#gem 'jquery-datatables-rails', '~> 3.3.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4'
# haml support
gem 'haml-rails'
gem 'simple_form'
gem 'cocoon' # nested_form helper
gem 'will_paginate'
gem 'will_paginate-bootstrap'
gem 'bootstrap-wysihtml5-rails'

# Draper as model decorator
gem 'draper'
gem 'active_model_serializers'

# Use Unicorn as the app server
gem 'unicorn'
gem 'whenever', require: false
gem 'delayed_job_active_record'
gem 'daemons'

# image and pdf uploader
gem 'carrierwave'
gem 'rmagick'

# user rights management
gem 'devise'
gem 'devise-i18n-views'
gem 'cancancan'

# charts
gem 'lazy_high_charts'

# browser detection
gem 'browser'

# extra validations
gem 'validates_email_format_of'

# ics export
gem 'icalendar'

# markdown
gem 'redcarpet'

# datetimepicker for simple_form
gem 'momentjs-rails', github: 'egeek/momentjs-rails'
gem 'datetimepicker-rails', github: 'zpaulovics/datetimepicker-rails', branch: 'master', submodules: true

group :development do
  gem 'capistrano', '~> 2', require: false
  gem 'rvm-capistrano', require: false
  gem 'capistrano-nginx-unicorn', require: false
  gem 'capistrano_rsync_with_remote_cache', require: false

  # to test email
  gem 'recipient_interceptor'
end

group :development, :test, :test_dump do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  #gem 'byebug'
  
  gem 'pry'
  gem 'pry-byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  #gem 'web-console', '~> 2.0'
  gem 'timecop'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-commands-rspec'

  gem 'rspec-rails'
  gem 'rspec-collection_matchers'
  gem 'guard-rspec', require: false
  gem 'database_cleaner'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'capybara-screenshot'
end

