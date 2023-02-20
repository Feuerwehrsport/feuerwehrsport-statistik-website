# frozen_string_literal: true

class API::ImportRequestsController < API::BaseController
  api_actions :create,
              default_form: %i[compressed_data]

  protected

  def after_create
    deliver_later(ImportRequestMailer, :new_request, form_resource)
    super
  end
end
