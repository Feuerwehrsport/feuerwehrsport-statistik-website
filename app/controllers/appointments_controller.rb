require 'icalendar'

class AppointmentsController < ResourceController
  def index
    @rows = Appointment.upcoming.decorate

    if request.format.ics?
      calendar_response("feuerwehrsport-statistik-termine", @rows)
    end
  end

  def show
    @appointment = Appointment.find(params[:id]).decorate
    
    if request.format.ics?
      calendar_response(@appointment.to_s.parameterize, [@appointment])
    end
  end

  protected

  def calendar_response(filename, rows)
    response.headers['Content-Disposition'] = "attachment; filename=\"#{filename}.ics\""
    calendar = Icalendar::Calendar.new
    rows.each do |row|
      calendar.add_event(row.to_icalendar_event)
    end
    calendar.publish
    render text: calendar.to_ical
  end
end
