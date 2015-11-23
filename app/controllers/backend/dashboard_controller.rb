module Backend
  class DashboardController < BackendController
    def index
      @models = [Person, Place, Event]
    end
  end
end