class Backend::DashboardsController < Backend::BackendController
  RESOURCE_MODELS = [
    ::BLA::Badge,
    ::Series::Round,
    AdminUser,
    Appointment,
    Competition,
    CompetitionFile,
    Event,
    GroupScore,
    GroupScoreCategory,
    GroupScoreType,
    Link,
    Nation,
    NewsArticle,
    Person,
    PersonParticipation,
    PersonSpelling,
    Place,
    Score,
    ScoreType,
    Team,
  ].freeze

  def index
    @models = RESOURCE_MODELS.sort_by { |m| m.model_name.human(count: 0) }
    redirect_to new_session_path if current_login.blank?
  end
end
