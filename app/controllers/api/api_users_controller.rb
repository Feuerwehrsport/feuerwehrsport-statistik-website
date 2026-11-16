# frozen_string_literal: true

class Api::ApiUsersController < Api::BaseController
  api_actions :create,
              clean_cache_disabled: true,
              default_form: %i[name email_address]

  rate_limit to: 10, within: 10.minutes, only: %i[create challenge], store: Rails.configuration.x.api_login_store,
             with: -> { failed_with_status('Zu viele Anmeldeversuche. Bitte versuchen Sie es später erneut.') }
  before_action :verify_login_protection, only: :create

  def status
    success
  end

  # arithmetic question for the login form, the answer stays on the server
  def challenge
    success(question: ApiLoginChallenge.issue(session))
  end

  def logout
    reset_session
    @current_api_user = nil
    success
  end

  protected

  def after_create
    session[:api_user_id] = resource.id
    remove_instance_variable(:@current_api_user)
    success
  end

  def build_resource
    super.tap { |r| r.request_headers = request.headers }
  end

  private

  # honeypot field "website" must stay empty, the arithmetic question must be answered correctly and not too fast
  def verify_login_protection
    message = if params[:website].present?
                'Die Anmeldung ist fehlgeschlagen.'
              else
                ApiLoginChallenge.verify(session, params[:captcha_answer])
              end
    failed(message:) if message
  end

  def failed_with_status(message)
    render json: { success: false, login: false, message: }, status: :too_many_requests
  end
end
