module Backend
  class DashboardController < BackendController
    def index
      @models = [Person, Place, Event, ScoreType, AdminUser]
    end
  end
end