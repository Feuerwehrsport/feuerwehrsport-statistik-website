class API::Series::RoundsController < API::BaseController
  include API::CRUD::IndexAction
  include API::CRUD::CreateAction
  include API::CRUD::ShowAction
  include API::CRUD::UpdateAction

  protected

  def permitted_attributes
    super.permit(:name, :year, :official, :aggregate_type, :full_cup_count)
  end
end