module Backend
  class AppointmentsController < ResourcesController
    protected

    def permitted_attributes
      super.permit(:name, :dated_at, :description, :place_id, :event_id, :disciplines)
    end
  end
end