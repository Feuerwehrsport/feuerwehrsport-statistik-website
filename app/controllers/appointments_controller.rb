class AppointmentsController < ResourceController
  resource_actions :show, :index, cache: :show
  decorates_assigned :comp_reg_competitions

  export_index :xlsx do |t|
    t.col :dated_at
    t.col :name
    t.col :place
    t.col :event
    t.col :disciplines
    t.col :url
  end

  def index
    @comp_reg_competitions = Registrations::Competition.published.overview

    if request.format.ics?
      calendar_response('feuerwehrsport-statistik-termine', collection.decorate, 'PUBLISH')
    end
  end

  def show
    if request.format.ics?
      calendar_response(resource.decorate.to_s.parameterize, [resource.decorate], 'REQUEST')
    end
  end

  protected

  def calendar_response(filename, rows, method)
    response.headers['Content-Disposition'] = "attachment; filename=\"#{filename}.ics\""
    calendar = Icalendar::Calendar.new
    rows.each do |row|
      calendar.add_event(row.to_icalendar_event)
    end
    calendar.ip_method = method
    render text: calendar.to_ical
  end

  def find_collection
    super.upcoming.includes(:place, :event)
  end
end
