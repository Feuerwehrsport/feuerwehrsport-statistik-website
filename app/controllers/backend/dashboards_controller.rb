# frozen_string_literal: true

class Backend::DashboardsController < Backend::BackendController
  RESOURCE_MODELS = [
    ::Bla::Badge,
    ::Series::Round,
    AdminUser,
    Competition,
    CompetitionFile,
    Event,
    GroupScore,
    GroupScoreCategory,
    GroupScoreType,
    Link,
    Nation,
    Person,
    PersonParticipation,
    PersonSpelling,
    Place,
    Score,
    ScoreType,
    Team,
    TeamSpelling,
  ].freeze

  def index
    @models = RESOURCE_MODELS.sort_by { |m| m.model_name.human(count: 0) }
    redirect_to new_session_path if current_login.blank?
  end
end
