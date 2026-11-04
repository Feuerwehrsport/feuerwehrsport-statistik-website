# frozen_string_literal: true

# session handling for logins (replacement for the former m3 login session)
module Authentication
  extend ActiveSupport::Concern

  SESSION_KEY = :login_id

  included do
    helper_method :current_login
  end

  protected

  def current_login
    return @current_login if defined?(@current_login)

    @current_login = (Login.not_expired.find_by(id: session[SESSION_KEY]) if session[SESSION_KEY].present?)
  end

  def start_session(login)
    requested_url = session[:requested_url_before_login]
    reset_session # prevent session fixation
    session[:requested_url_before_login] = requested_url if requested_url
    session[SESSION_KEY] = login.id
    @current_login = login
  end

  def terminate_session
    reset_session
    @current_login = nil
  end

  def current_ability
    @current_ability ||= ::Ability.new(current_login)
  end
end
