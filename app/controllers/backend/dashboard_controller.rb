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
        PersonParticipation,
        Place,
        Score,
        ScoreType,
      ]
    end
  end
end