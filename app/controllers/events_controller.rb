class EventsController < ResourceController
  resource_actions :show, :index, cache: %i[show index]

  def index
    @chart = Chart::EventIndex.new(events: collection.decorate, context: view_context)
  end

  def show
    competitions = resource.competitions.includes(:place)
    @chart = Chart::CompetitionsScoreOverview.new(competitions: competitions, context: view_context)
    @competitions = competitions.decorate
    @competitions_discipline_overview = Calculation::CompetitionsScoreOverview.new(competitions.map(&:id)).disciplines
  end

  protected

  def find_collection
    super.competition_count
  end
end
