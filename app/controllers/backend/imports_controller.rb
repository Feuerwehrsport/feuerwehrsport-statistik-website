# frozen_string_literal: true

class Backend::ImportsController < Backend::BackendController
  include Backend::ImportCompetitionSelection
  include ChangeLogging

  before_action { authorize!(:manage, Competition) }

  def index; end

  # "Mannschaftswertung" of the selected competition
  def score_type
    competition = Competition.find(params[:competition_id])
    before_hash = serialize_for_log(competition, CompetitionSerializer)
    competition.update!(score_type_id: params[:score_type_id].presence)
    log_change(competition, serializer: CompetitionSerializer, action: 'update-competition:score-type', before_hash:)
    clean_cache
    redirect_back_or_to backend_imports_path, notice: 'Mannschaftswertung gespeichert.'
  end
end
