# frozen_string_literal: true

require 'cancan'
require 'bcrypt'
require 'haml'
require 'draper'
require 'simple_form'
require 'carrierwave'
require 'remotipart'
require 'acts_as_list'
require 'mini_magick'
require 'bootstrap-sass'
require 'valid_email2'
require 'momentjs-rails'
require 'bootstrap3-datetimepicker-rails'
require 'modernizr-rails'
require 'delayed_job_active_record'
require 'will_paginate'
require 'will_paginate-bootstrap'
require 'turbolinks'
require 'sassc/rails'

# exports
require 'caxlsx_rails'
require 'csv_builder'

if Rails.env.development?
  begin
    require 'pry'
  rescue LoadError
    puts 'pry is yet not available'
  end
end

class M3::Engine < Rails::Engine
  config.m3 = ActiveSupport::OrderedOptions.new
  config.m3.session = ActiveSupport::OrderedOptions.new
  config.m3.session.login_url = { controller: 'm3/login/sessions', action: :new }
  config.m3.login = ActiveSupport::OrderedOptions.new
  config.m3.login.send_verification_mail = true

  initializer :assets do |_config|
    Rails.application.config.assets.precompile += %w[m3_bootstrap_v1/index.css]
  end

  initializer :error_handling do
    Rails.application.config.exceptions_app = Rails.application.routes
  end

  initializer :delayed do
    require_dependency 'm3/delayable'
    require_dependency 'm3/mailer_configuration'

    Delayed::Worker.destroy_failed_jobs = false
    Delayed::Worker.sleep_delay = 10
    Delayed::Worker.max_attempts = 1
    Delayed::Worker.max_run_time = 20.minutes
    Delayed::Worker.read_ahead = 10
    Delayed::Worker.default_queue_name = 'default'
    Delayed::Worker.delay_jobs = !(Rails.env.test? || Rails.env.development?)
  end

  initializer :delayed do
    WillPaginate.per_page = 10
  end
end
