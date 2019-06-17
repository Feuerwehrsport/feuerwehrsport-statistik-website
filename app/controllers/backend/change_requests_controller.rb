class Backend::ChangeRequestsController < Backend::BackendController
  def index
    authorize!(:manage, ChangeRequest)
  end
end
