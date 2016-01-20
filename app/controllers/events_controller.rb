class EventsController < ResourceController
  cache_actions :index, :show

  def index
    @events = Event.competition_count.decorate
    @chart = Chart::EventIndex.new(events: @events)
  end

  def show
    @event = Event.find(params[:id])
    @competitions = @event.competitions.with_disciplines_count.includes(:place).decorate
    @chart = Chart::CompetitionsScoreOverview.new(competitions: @competitions)
    @competitions_discipline_overview = Calculation::CompetitionsScoreOverview.new(@competitions).disciplines
    @page_title = "#{@event.decorate} - Wettkampftyp"
  end
end
