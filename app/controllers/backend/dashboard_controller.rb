module Backend
  class DashboardController < BackendController
    def index
      @models = [AdminUser, Competition, Event, GroupScore, Person, Place, ScoreType]
    end
  end
end