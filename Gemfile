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

# Draper as model decorator
gem 'draper'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
gem 'unicorn'
gem 'whenever', require: false

# image uploader
gem 'carrierwave'
gem 'rmagick'

# charts
# gem "chartkick"
# gem "highcharts-rails"
gem 'lazy_high_charts'

gem 'responders', '~> 2.0'

group :development do
  gem 'capistrano', '~> 2', require: false
  gem 'rvm-capistrano', require: false
  gem 'capistrano-nginx-unicorn', require: false
  gem 'capistrano_rsync_with_remote_cache', require: false
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  #gem 'byebug'
  
  gem 'pry'
  gem 'pry-byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  #gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'rspec-rails'
end

