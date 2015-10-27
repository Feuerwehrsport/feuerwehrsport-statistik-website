class PlacesController < ResourceController
  def index
    @rows = Place.competition_count
  end

  def show
    @competitions = Place.find(params[:id]).competitions.with_disciplines_count.includes(:event).decorate
  end
end
