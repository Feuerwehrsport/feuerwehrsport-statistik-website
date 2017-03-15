class Backend::DashboardsController < Backend::BackendController
  def index
  end

  def administration
    @models = ResourcesController.models.sort_by { |m| m.model_name.human(count: 0) }
  end
end