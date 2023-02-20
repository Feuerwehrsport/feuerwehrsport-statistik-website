# frozen_string_literal: true

class Backend::ChangeRequestsController < Backend::BackendController
  def index
    authorize!(:manage, ChangeRequest)
  end
end
