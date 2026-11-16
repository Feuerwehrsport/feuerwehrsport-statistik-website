# frozen_string_literal: true

class Contributions::TeamsController < Contributions::BaseController
  def new
    @team = Team.new(status: :fire_station)
    authorize!(:create, @team)
  end

  def create
    @team = Team.new(params.expect(team: %i[name shortcut status]))
    authorize!(:create, @team)

    saved = Team.transaction { @team.save && log_change(@team, serializer: TeamSerializer) }
    if saved
      clean_cache
      render :created
    else
      render :new, status: :unprocessable_content
    end
  end
end
