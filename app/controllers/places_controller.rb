class PlacesController < ResourceController
  cache_actions :index, :show

  def index
    @places = Place.competition_count.decorate
  end

  def show
    @place = Place.find(params[:id])
    @competitions = @place.competitions.with_disciplines_count.includes(:event).decorate
    @chart = Chart::CompetitionsScoreOverview.new(competitions: @competitions)
    @competitions_discipline_overview = Calculation::CompetitionsScoreOverview.new(@competitions.map(&:id)).disciplines
    @page_title = "#{@place.decorate} - Wettkampfort"
  end
end
