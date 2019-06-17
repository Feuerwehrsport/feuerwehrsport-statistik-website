class AppointmentsController < ResourceController
  resource_actions :show, :index, cache: :show
  decorates_assigned :registrations_competitions

  export_index :xlsx do |t|
    t.col :dated_at
    t.col :name
    t.col :place
    t.col :event
    t.col :disciplines
    t.col :url
  end

  def index
    @registrations_competitions = Registrations::Competition.published.overview

    calendar_response('feuerwehrsport-statistik-termine', collection.decorate, 'PUBLISH') if request.format.ics?
  end

  def show
    calendar_response(resource.decorate.to_s.parameterize, [resource.decorate], 'REQUEST') if request.format.ics?
  end

  protected

  def calendar_response(filename, rows, method)
    response.headers['Content-Disposition'] = "attachment; filename=\"#{filename}.ics\""
    calendar = Icalendar::Calendar.new
    rows.each do |row|
      calendar.add_event(row.to_icalendar_event)
    end
    calendar.ip_method = method
    render body: calendar.to_ical, content_type: Mime[:ics]
  end

  def find_collection
    super.upcoming.includes(:event)
  end
end
