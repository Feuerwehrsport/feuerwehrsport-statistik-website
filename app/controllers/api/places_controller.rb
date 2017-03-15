class API::PlacesController < API::BaseController
  include API::CRUD::CreateAction
  include API::CRUD::ShowAction
  include API::CRUD::IndexAction
  include API::CRUD::UpdateAction
  include API::CRUD::ChangeLogSupport

  protected

  def create_permitted_attributes
    permitted_attributes.permit(:name)
  end

  def update_permitted_attributes
    permitted_attributes.permit(:latitude, :longitude)
  end
end