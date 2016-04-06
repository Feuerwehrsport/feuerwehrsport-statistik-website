module API
  class AppointmentsController < BaseController
    include CRUD::CreateAction
    include CRUD::ShowAction
    include CRUD::UpdateAction
    include CRUD::ChangeLogSupport

    protected

    def permitted_attributes
      super.permit(:name, :description, :dated_at, :disciplines, :place_id, :event_id)
    end

    def build_instance
      resource_class.new(creator: current_user)
    end

    def resource_instance_show_object
      object = super
      object.current_user = current_user
      object
    end
  end
end
