# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include CallbackHelpers
  include DefaultResources
  include DefaultParentResources
  include ActionManager
  include DefaultActions
  include ReturnToPage
  include IndexStructures
  include FormStructures
  include FilterStructures
  include Authentication
  include ControllerTranslation

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  layout :select_layout

  # handle access denied
  rescue_from CanCan::AccessDenied do |_exception|
    if current_login.present?
      flash[:alert] = t3(:access_denied, scope: :errors)
      redirect_to access_denied_redirect_path
    else
      flash[:alert] = t3(:login_required, scope: :errors)
      session[:requested_url_before_login] = request.fullpath if request.format == :html
      redirect_to access_denied_login_path
    end
  end

  helper ResourceHelper

  include Caching::CacheSupport
  include PageTitleHelper
  include MapSupport

  helper_method :current_admin_user, :current_user

  before_action :redirect_to_domain

  rescue_from RangeError, with: -> do
    raise ActiveRecord::RecordNotFound
  end

  protected

  # main_app: also resolve correctly inside mounted engines (e.g. mission control)
  def access_denied_redirect_path
    main_app.root_path
  end

  def access_denied_login_path
    main_app.new_session_path
  end

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

  def redirect_to_domain
    return if request.host == default_url_options[:host]

    redirect_to url_for(default_url_options), status: :moved_permanently, allow_other_host: true
  end
end
