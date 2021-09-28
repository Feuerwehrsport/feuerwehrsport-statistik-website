# frozen_string_literal: true

class M3::ApplicationController < ActionController::Base
  include M3::CallbackHelpers
  include DefaultResources
  include DefaultParentResources
  include ActionManager
  include WebsiteContext
  include DefaultActions
  include ReturnToPage
  include IndexStructures
  include FormStructures
  include FilterStructures
  include Authorization
  include MailerSupport
  include ControllerTranslation
  include TrackingKeys

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

  def access_denied_redirect_path
    root_path
  end

  def access_denied_login_path
    Rails.application.config.m3.session.login_url
  end
end
