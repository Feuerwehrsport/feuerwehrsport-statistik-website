# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'm3/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'm3'
  s.version     = M3::VERSION
  s.authors     = ['Sebastian Gaul']
  s.email       = ['sebastian@mgvmedia.com']
  s.homepage    = 'http://sgaul.de'
  s.summary     = 'M3 Core features for rapid development'
  s.description = 'M3 Core features for rapid development'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.required_ruby_version = '>= 2.6.0'
end
