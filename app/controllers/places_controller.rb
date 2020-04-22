class PlacesController < ResourceController
  resource_actions :show, :index, cache: %i[show index]
  map_support_at :show, :index

  def show
    super
    competitions = resource.competitions.includes(:event)
    @chart = Chart::CompetitionsScoreOverview.new(competitions: competitions, context: view_context)
    @competitions = competitions.decorate
    @competitions_discipline_overview = Calculation::CompetitionsScoreOverview.new(@competitions.map(&:id)).disciplines
  end

  protected

  def find_collection
    super.competition_count
  end
end
