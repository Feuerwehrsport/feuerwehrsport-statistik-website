module Backend
  class DashboardController < BackendController
    def index
      @models = ResourcesController.models.sort_by { |m| m.model_name.human(count: 0) }
    end
  end
end