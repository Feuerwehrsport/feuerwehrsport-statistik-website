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
  s.test_files = Dir['test/**/*']
  s.required_ruby_version = '>= 2.6.0'

  s.add_dependency 'acts_as_list'
  s.add_dependency 'bcrypt'
  s.add_dependency 'bootsnap'
  s.add_dependency 'bootstrap-sass', '~> 3.0'
  s.add_dependency 'cancancan'
  s.add_dependency 'carrierwave'
  s.add_dependency 'draper', '~> 3.0'
  s.add_dependency 'haml-rails', '~> 1.0'
  s.add_dependency 'mini_magick', '~> 4.0'
  s.add_dependency 'pg'
  s.add_dependency 'puma'
  s.add_dependency 'rails', '~> 5.2.0'
  s.add_dependency 'remotipart', '~> 1.0'
  s.add_dependency 'sassc-rails'
  s.add_dependency 'simple_form', '~> 4.0'
  s.add_dependency 'turbolinks', '~> 5.0'
  s.add_dependency 'will_paginate-bootstrap', '~> 1.0'

  # image optimazing
  s.add_dependency 'image_optim', '>= 0.28.0'
  s.add_dependency 'image_optim_pack'

  # exports
  s.add_dependency 'caxlsx'
  s.add_dependency 'caxlsx_rails'
  s.add_dependency 'csv_builder', '~> 2.1.0'

  # background jobs
  s.add_dependency 'daemons', '~> 1.2.0'
  s.add_dependency 'delayed_job_active_record', '~> 4.1.0'
  s.add_dependency 'whenever', '~> 0.9.0'

  s.add_dependency 'bootstrap3-datetimepicker-rails', '~> 4.17.37'
  s.add_dependency 'modernizr-rails', '~> 2.7.1'
  s.add_dependency 'momentjs-rails', '>= 2.9.0'
  s.add_dependency 'valid_email2'
end
