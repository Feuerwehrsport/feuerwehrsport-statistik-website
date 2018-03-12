source 'https://rubygems.org'

gem 'm3', path: 'm3'
gem 'pg', '~> 0.20.0' # eliminated deprecation warnings
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
gem 'prawn'
gem 'prawn-table'
gem 'prawnto'
gem 'rqrcode_png'
gem 'axlsx', '~> 3.0.0.pre'

# markdown
gem 'redcarpet'

# validation
gem 'schema_validations'
gem 'schema_plus_views'

group :production do
  gem 'unicorn'
  gem 'm3_log_file_parser', git: 'https://github.com/lichtbit/m3_log_file_parser.git'
end

group :development, :test do
  # Bug in Bundler Version 1.11.2: https://github.com/bundler/bundler/issues/3981
  gem 'm3_rspec', require: false, git: 'ssh://gitolite3@stadthafen-rails/m3_rspec', ref: 'a58e53d40b8de228667468789279d54d120bc19f'
  # gem 'm3_rspec', path: '../m3_rspec'
  gem 'rubocop-rspec'
  gem 'haml_lint', require: false
end

group :development do
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'm3_capistrano', require: false, git: 'ssh://gitolite3@stadthafen-rails/m3_capistrano'
  # gem 'm3_capistrano', path: '../m3_capistrano'
end
