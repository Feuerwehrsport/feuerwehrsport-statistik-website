class TeamsController < ResourceController
  def index
    @teams = Team.with_members_and_competitions_count.decorate
    @charts = Chart::TeamOverview.new
  end

  def show
    @team_undecorared = Team.find(params[:id])
    @team = @team_undecorared.decorate
    @chart = Chart::TeamShow.new(team: @team)
    @team_members = @team_undecorared.members_with_discipline_count.map(&:decorate)
    @team_competitions = @team_undecorared.competitions_with_discipline_count.map(&:decorate)
    @group_assessments = @team_undecorared.group_assessments
    @group_disciplines = @team_undecorared.group_disciplines
    @series_round_structs = Series::Round.for_team(@team.id)
    @max_cup_count = @series_round_structs.values.flatten.map(&:cups).map(&:count).max
  end
end
