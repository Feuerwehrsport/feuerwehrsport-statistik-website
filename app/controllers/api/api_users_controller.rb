class API::APIUsersController < API::BaseController
  api_actions :create,
    default_form: [:name, :email_address]

  def status
    success
  end

  def logout
    reset_session
    @current_api_user = nil
    success
  end

  protected

  def after_create
    session[:api_user_id] = resource.id
    success
  end

  def build_resource
    super.tap { |r| r.request_headers = request.headers }
  end
end