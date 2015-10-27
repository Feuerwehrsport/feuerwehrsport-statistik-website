class EventsController < ResourceController
  def index
    @rows = Event.competition_count
  end

  def show
    @rows = Event.find(params[:id]).competitions
  end
end
