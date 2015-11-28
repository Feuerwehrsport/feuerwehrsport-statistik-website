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
        News,
        Person,
        PersonParticipation,
        Place,
        Score,
        ScoreType,
        Team,
      ]
    end
  end
end