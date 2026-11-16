# frozen_string_literal: true

# country/state of a team ("Bundesland bearbeiten")
class Contributions::TeamStatesController < Contributions::BaseController
  before_action :assign_team

  def edit; end

  def update
    state = params[:state].presence
    if state && !State::ALL.key?(state)
      @error = 'Bitte wähle ein Bundesland aus der Liste.'
      return render :edit, status: :unprocessable_content
    end

    before_hash = TeamSerializer.new(@team.decorate).as_json
    Team.transaction do
      @team.update!(state:)
      log_change(@team, serializer: TeamSerializer, action: 'update-team:state', before_hash:)
    end
    clean_cache
    render :updated
  end

  private

  def assign_team
    @team = Team.find(params[:team_id])
    authorize!(:update, @team)
  end
end
