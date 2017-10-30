class EventsController < ResourceController
  resource_actions :show, :index, cache: %i[show index]

  def index
    @chart = Chart::EventIndex.new(events: collection.decorate)
  end

  def show
    competitions = resource.competitions.includes(:place)
    @chart = Chart::CompetitionsScoreOverview.new(competitions: competitions)
    @competitions = competitions.decorate
    @competitions_discipline_overview = Calculation::CompetitionsScoreOverview.new(competitions.map(&:id)).disciplines
  end

  protected

  def find_collection
    super.competition_count
  end
end
