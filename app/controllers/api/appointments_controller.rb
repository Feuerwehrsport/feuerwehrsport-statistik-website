module API
  class AppointmentsController < BaseController
    include CRUD::CreateAction

    protected

    def permitted_attributes
      super.permit(:name, :description, :dated_at, :disciplines, :place_id, :event_id)
    end
  end
end
