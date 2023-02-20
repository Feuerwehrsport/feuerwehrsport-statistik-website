# frozen_string_literal: true

module API::LoginActions
  protected

  def current_user
    current_admin_user || current_api_user
  end

  def current_api_user
    @current_api_user ||= APIUser.find_by(id: session[:api_user_id])
  end

  def login_status
    current_user.present?
  end
end
