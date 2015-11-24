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
        Nation,
        Person, 
        Place, 
        ScoreType
      ]
    end
  end
end