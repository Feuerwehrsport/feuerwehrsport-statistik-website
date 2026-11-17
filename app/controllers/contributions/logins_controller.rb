# frozen_string_literal: true

# anonymous login with name and/or email address, protected by ApiLoginChallenge
class Contributions::LoginsController < Contributions::BaseController
  skip_before_action :require_contributor
  rate_limit to: 10, within: 10.minutes, only: :create, store: Rails.configuration.x.api_login_store,
             with: -> { render_form('Zu viele Anmeldeversuche. Bitte versuch es später noch einmal.') }

  def new
    @api_user = ApiUser.new
    @question = ApiLoginChallenge.issue(session)
  end

  def create
    @api_user = ApiUser.new(params.fetch(:api_user, {}).permit(:name, :email_address))
    @api_user.request_headers = request.headers

    message = ApiLoginChallenge.verify_request(session, params)
    return render_form(message) if message
    return render_form(nil) unless @api_user.save

    session[:api_user_id] = @api_user.id
    redirect_to return_to_path
  end

  private

  def render_form(message)
    @message = message
    @api_user ||= ApiUser.new
    @question = ApiLoginChallenge.issue(session)
    render :new, status: :unprocessable_content
  end

  # only paths of other contribution dialogs are allowed as target
  def return_to_path
    path = params[:return_to].to_s
    path.start_with?('/contributions/') && !path.start_with?('//') ? path : root_path
  end
end
