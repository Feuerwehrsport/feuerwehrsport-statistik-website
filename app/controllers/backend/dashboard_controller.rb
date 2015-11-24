module Backend
  class DashboardController < BackendController
    def index
      @models = [
        AdminUser, 
        Competition, 
        Event, 
        GroupScore, 
        GroupScoreCategory, 
        GroupScoreType, 
        Person, 
        Place, 
        ScoreType
      ]
    end
  end
end