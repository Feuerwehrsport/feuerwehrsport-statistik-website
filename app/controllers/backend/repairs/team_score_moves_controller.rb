# frozen_string_literal: true

# "Team auseinanderziehen": moves selected scores of a team to another team
class Backend::Repairs::TeamScoreMovesController < Backend::BackendController
  include ChangeLogging

  backend_actions :new, :create, clean_cache_disabled: true

  default_form do |f|
    f.association :source_team, as: :association_select
    f.association :destination_team, as: :association_select
  end

  def execute
    authorize!(:create, Repairs::TeamScoreMove)
    source_team = Team.find(params[:source_team_id])
    destination_team = Team.find(params[:destination_team_id])
    records = Score.where(team: source_team, id: params[:score_ids]).to_a +
              GroupScore.where(team: source_team, id: params[:group_score_ids]).to_a
    return redirect_back_to_selection(source_team, destination_team) if records.empty?

    ActiveRecord::Base.transaction { records.each { |record| move(record, destination_team) } }
    clean_cache
    redirect_to backend_root_path,
                notice: "#{records.size} Zeiten von #{source_team.name} nach #{destination_team.name} verschoben."
  end

  protected

  def after_create
    render :create
  end

  private

  def move(record, destination_team)
    serializer = record.is_a?(Score) ? ScoreSerializer : GroupScoreSerializer
    action = record.is_a?(Score) ? 'update-score:team' : 'update-group-score:team'
    before_hash = serialize_for_log(record, serializer)
    record.update!(team: destination_team)
    log_change(record, serializer:, action:, before_hash:)
  end

  def redirect_back_to_selection(source_team, destination_team)
    redirect_to new_backend_repairs_team_score_move_path(
      repairs_team_score_move: { source_team_id: source_team.id, destination_team_id: destination_team.id },
    ), alert: 'Keine Zeiten ausgewählt.'
  end
end
