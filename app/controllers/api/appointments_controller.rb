module API
  class AppointmentsController < BaseController
    include CRUD::CreateAction
    include CRUD::ShowAction
    include CRUD::UpdateAction

    protected

    def create_permitted_attributes
      super.permit(:name, :description, :dated_at, :disciplines, :place_id, :event_id)
    end

    def update_permitted_attributes
      permitted_keys = []
      permitted_keys.push(:name, :description, :dated_at, :disciplines, :place_id, :event_id) if can?(:correct, resource_instance)
      permitted_attributes.permit(*permitted_keys)
    end
  end
end
