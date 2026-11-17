# frozen_string_literal: true

class Api::ImportRequestsController < Api::BaseController
  include ActionController::HttpAuthentication::Token::ControllerMethods

  api_actions :create,
              default_form: %i[compressed_data]

  # Feusport sends "Authorization: Bearer <token>". Without this header only logged in admins can create.
  prepend_before_action :authenticate_import_token, only: :create

  protected

  def after_create
    ImportRequestMailer.with(import_request: form_resource).new_request.deliver_later
    super
  end

  def current_ability
    return super unless @import_token

    @current_ability ||= ::Ability.new(@import_token, nil)
  end

  private

  def authenticate_import_token
    return if request.authorization.blank?

    @import_token = authenticate_with_http_token { |token, _options| ImportToken.authenticate(token) }
    render json: { success: false, message: 'Invalid token' }, status: :unauthorized unless @import_token
  end
end
