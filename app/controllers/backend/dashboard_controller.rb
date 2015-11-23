module Backend
  class DashboardController < BackendController
    def index
      @models = [Person, Place]
    end
  end
end