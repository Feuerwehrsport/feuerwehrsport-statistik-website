module API
  class TeamsController < BaseController
    include CRUD::CreateAction
    include CRUD::ShowAction
    include CRUD::UpdateAction
    include CRUD::IndexAction
    include MergeAction

    protected

    def resource_instance_show_object
      params[:extended].present? ? ExtendedTeamSerializer.new(resource_instance) : super
    end

    def create_permitted_attributes
      permitted_attributes.permit(:name, :shortcut, :status)
    end

    def update_permitted_attributes
      permitted_keys = [:latitude, :longitude]
      permitted_keys.push(:name, :shortcut, :status, :image_change_request) if can?(:correct, resource_instance.object)
      permitted_attributes.permit(*permitted_keys)
    end
  end
end
