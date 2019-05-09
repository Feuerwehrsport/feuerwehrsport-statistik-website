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
gem 'prawn-rails'
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
  gem 'm3_rspec', path: 'm3_rspec'
  gem 'haml_lint', require: false
  gem 'rubocop-performance'
end

group :development do
  gem 'spring'

  gem 'm3_capistrano', require: false, git: 'ssh://gitolite3@stadthafen-rails/m3_capistrano'
  # gem 'm3_capistrano', path: '../m3_capistrano'
  gem 'capistrano_rsync_with_remote_cache', git: 'https://github.com/Lichtbit/capistrano_rsync_with_remote_cache'
end

group :test do
  gem 'simplecov', require: false
end
