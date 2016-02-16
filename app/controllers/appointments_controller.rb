require 'icalendar'

class AppointmentsController < ResourceController
  cache_actions :show

  def index
    @rows = Appointment.upcoming.includes(:place, :event).decorate
    @comp_reg_competitions = CompReg::Competition.published.decorate

    if request.format.ics?
      calendar_response("feuerwehrsport-statistik-termine", @rows, "PUBLISH")
    end
  end

  def show
    @appointment = Appointment.find(params[:id]).decorate
    @page_title = "#{l(@appointment.dated_at, format: :german)} #{@appointment} - Wettkampftermin"
    if request.format.ics?
      calendar_response(@appointment.to_s.parameterize, [@appointment], "REQUEST")
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
end
