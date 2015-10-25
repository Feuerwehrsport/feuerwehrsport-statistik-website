class PlacesController < ResourceController
  def index
    @rows = Place.competition_count
  end

  def show
    @rows = Place.find(params[:id]).competitions
  end
end
