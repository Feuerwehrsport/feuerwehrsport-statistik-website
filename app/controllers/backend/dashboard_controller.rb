module Backend
  class DashboardController < BackendController
    def index
      @models = [Person, Place, Event, ScoreType]
    end
  end
end