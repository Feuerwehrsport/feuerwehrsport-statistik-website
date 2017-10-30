class CompetitionsController < ResourceController
  resource_actions :show, :index, cache: %i[show index]

  def index
    super
    @chart = Chart::CompetitionsScoreOverview.new(competitions: collection)
    @competitions_discipline_overview = Calculation::CompetitionsScoreOverview.new(collection.map(&:id)).disciplines
  end

  def show
    @calc = Calculation::Competition.new(resource)
  end

  protected

  def find_collection
    super.includes(:event, :place)
  end
end
