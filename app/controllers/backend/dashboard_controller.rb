module Backend
  class DashboardController < BackendController

    def index
      @models = ResourcesController.models
    end
  end
end