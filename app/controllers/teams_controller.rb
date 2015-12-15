class TeamsController < ResourceController
  def index
    @teams = Team.with_members_and_competitions_count.decorate
    @charts = Chart::TeamOverview.new
  end

  def show
  end
end
