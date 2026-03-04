# frozen_string_literal: true

require 'cancan'
require 'bcrypt'
require 'haml'
require 'draper'
require 'simple_form'
require 'carrierwave'
require 'mini_magick'
require 'bootstrap-sass'
require 'valid_email2'
require 'will_paginate'
require 'will_paginate-bootstrap'
require 'sassc/rails'

# exports
require 'caxlsx_rails'

if Rails.env.development?
  begin
    require 'pry'
  rescue LoadError
    Rails.logger.warn 'pry is yet not available'
  end
end

module M3
end

class M3::Engine < Rails::Engine
  config.m3 = ActiveSupport::OrderedOptions.new
  config.m3.session = ActiveSupport::OrderedOptions.new
  config.m3.session.login_url = { controller: 'm3/login/sessions', action: :new }
  config.m3.login = ActiveSupport::OrderedOptions.new

  initializer :assets do |_config|
    Rails.application.config.assets.precompile += %w[m3_bootstrap_v1/index.css]
  end

  initializer :error_handling do
    Rails.application.config.exceptions_app = Rails.application.routes
  end

  initializer :will_paginate do
    WillPaginate.per_page = 10
  end
end
