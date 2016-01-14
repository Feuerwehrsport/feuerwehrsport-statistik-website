module API
  class AppointmentsController < BaseController
    include CRUD::CreateAction
    include CRUD::ShowAction
    include CRUD::UpdateAction

    protected

    def permitted_attributes
      super.permit(:name, :description, :dated_at, :disciplines, :place_id, :event_id)
    end
  end
end
