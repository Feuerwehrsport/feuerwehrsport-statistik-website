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
end
