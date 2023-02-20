# frozen_string_literal: true

class Api::ImportRequestsController < Api::BaseController
  api_actions :create,
              default_form: %i[compressed_data]

  protected

  def after_create
    ImportRequestMailer.with(import_request: form_resource).new_request.deliver_later
    super
  end
end
