class TeamsController < ResourceController
  resource_actions :show, :index, cache: %i[show index]

  def index
    super
    @charts = Chart::TeamOverview.new
  end

  def show
    super
    @chart = Chart::TeamShow.new(team: resource.decorate)
    @team_members = resource.members_with_discipline_count.map(&:decorate)
    @team_competitions = resource.competitions_with_discipline_count.map(&:decorate)
    @group_assessments = resource.group_assessments
    @group_disciplines = resource.group_disciplines
    @series_round_structs = {}
    @max_cup_count = {}
    %i[female male].each do |gender|
      @series_round_structs[gender] = Series::Round.for_team(resource.id, gender)
      @max_cup_count[gender] = @series_round_structs[gender].values.flatten.map(&:cups).map(&:count).max
    end
  end

  protected

  def find_collection
    super.with_members_and_competitions_count
  end
end
