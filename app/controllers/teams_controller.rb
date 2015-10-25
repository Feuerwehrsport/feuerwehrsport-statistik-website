class TeamsController < ResourceController
  def index
    @rows = Team.with_members_and_competitions_count
  end

  def show
  end
end
