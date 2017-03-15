class API::GroupScoreTypesController < API::BaseController
  include API::CRUD::CreateAction
  include API::CRUD::IndexAction
  include API::CRUD::ChangeLogSupport

  protected

  def create_permitted_attributes
    permitted_attributes.permit(:name, :discipline)
  end
  
  def base_collection
    super_collection = super
    super_collection = super_collection.where(discipline: params[:discipline]) if params[:discipline].present?
    super_collection
  end
end