class Backend::ImportsController < Backend::BackendController
  def index
    authorize!(:manage, Competition)
  end
end
