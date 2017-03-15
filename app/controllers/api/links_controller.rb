class API::LinksController < API::BaseController
  include API::CRUD::CreateAction
  include API::CRUD::ShowAction
  include API::CRUD::DestroyAction
  include API::CRUD::ChangeLogSupport

  protected

  def permitted_attributes
    super.permit(:label, :url, :linkable_type, :linkable_id)
  end
end