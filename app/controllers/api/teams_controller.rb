class API::TeamsController < API::BaseController
  include API::CRUD::CreateAction
  include API::CRUD::ShowAction
  include API::CRUD::UpdateAction
  include API::CRUD::IndexAction
  include API::CRUD::ChangeLogSupport
  include MergeAction

  protected

  def resource_instance_show_object
    params[:extended].present? ? ExtendedTeamSerializer.new(resource_instance) : super
  end

  def create_permitted_attributes
    permitted_attributes.permit(:name, :shortcut, :status)
  end

  def update_permitted_attributes
    permitted_keys = [:latitude, :longitude, :state]
    permitted_keys.push(:name, :shortcut, :status, :image_change_request) if can?(:correct, resource_instance.object)
    permitted_attributes.permit(*permitted_keys)
  end
end