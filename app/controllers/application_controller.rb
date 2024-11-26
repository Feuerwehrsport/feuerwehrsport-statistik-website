# frozen_string_literal: true

class ApplicationController < M3::ApplicationController
  include Caching::CacheSupport
  include PdfSupport
  include PageTitleHelper
  include MapSupport
  helper_method :current_admin_user, :current_user

  rescue_from RangeError, with: -> do
    raise ActiveRecord::RecordNotFound
  end

  protected

  def send_pdf(klass, *)
    pdf = klass.build(*)
    send_data(pdf.bytestream, filename: pdf.filename, type: 'application/pdf', disposition: 'inline')
  end

  def current_admin_user
    @current_admin_user ||= AdminUser.for_login(current_login)
  end

  def current_user
    current_admin_user
  end

  def current_ability
    @current_ability ||= ::Ability.new(current_user, current_login)
  end

  def select_layout
    'application'
  end

  def default_url_options
    Rails.application.config.default_url_options
  end
end
