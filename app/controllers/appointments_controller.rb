class AppointmentsController < ResourceController
  def index
    @rows = Appointment.upcoming.decorate
  end

  def show
    @appointment = Appointment.find(params[:id]).decorate
  end
end
