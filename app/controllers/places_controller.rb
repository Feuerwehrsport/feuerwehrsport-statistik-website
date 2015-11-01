class PlacesController < ResourceController
  def index
    @rows = Place.competition_count
  end

  def show
    @competitions = Place.find(params[:id]).competitions.with_disciplines_count.includes(:event).decorate
    @chart = Chart::Place.new(competitions: @competitions)
    @competitions_discipline_overview = Calculation::CompetitionsScoreOverview.new(@competitions.map(&:id)).disciplines
  end
end
