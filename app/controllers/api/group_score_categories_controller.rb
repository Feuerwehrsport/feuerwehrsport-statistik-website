class API::GroupScoreCategoriesController < API::BaseController
  include API::CRUD::CreateAction
  include API::CRUD::IndexAction
  include API::CRUD::ChangeLogSupport

  protected

  def create_permitted_attributes
    super.permit(:name, :group_score_type_id, :competition_id)
  end
  
  def base_collection
    super_collection = super
    super_collection = super_collection.discipline(params[:discipline]) if params[:discipline].present?
    super_collection = super_collection.where(competition_id: params[:competition_id]) if params[:competition_id].present?
    super_collection
  end
end