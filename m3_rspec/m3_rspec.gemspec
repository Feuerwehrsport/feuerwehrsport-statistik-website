# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

begin
  require 'pry'
rescue LoadError
  puts 'Pry is not available'
end

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'm3_rspec'
  s.version     = '1.1.0'
  s.authors     = ['Georg Limbach']
  s.email       = ['georg.limbach@lichtbit.com']
  s.license     = 'MIT'
  s.description = 'M3 Rspec feature set'
  s.summary     = 'M3 Rspec feature set'

  s.require_paths         = ['lib']
  s.required_ruby_version = '>= 2.6.0'

  s.files = `git ls-files`.split($INPUT_RECORD_SEPARATOR)

  s.add_dependency 'capybara', '>= 3.34.0'
  s.add_dependency 'capybara-email'
  s.add_dependency 'cuprite'
  s.add_dependency 'database_cleaner-active_record'
  s.add_dependency 'factory_bot_rails'
  s.add_dependency 'guard'
  s.add_dependency 'guard-rspec'
  s.add_dependency 'guard-rubocop'
  s.add_dependency 'launchy'
  s.add_dependency 'phashion'
  s.add_dependency 'pry'
  s.add_dependency 'pry-byebug'
  s.add_dependency 'rails-controller-testing'
  s.add_dependency 'rspec-collection_matchers'
  s.add_dependency 'rspec-rails'
  s.add_dependency 'rspec-retry'
  s.add_dependency 'rubocop', '>= 0.53.0'
  s.add_dependency 'rubocop-daemon'
  s.add_dependency 'rubocop-performance'
  s.add_dependency 'rubocop-rails'
  s.add_dependency 'rubocop-rspec'
  s.add_dependency 'timecop'
  s.add_dependency 'vcr'
  s.add_dependency 'webmock'
end
