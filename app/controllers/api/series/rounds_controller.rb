class API::Series::RoundsController < API::BaseController
  include API::CRUD::IndexAction
  include API::CRUD::CreateAction

  protected

  def permitted_attributes
    super.permit(:name, :year, :official, :aggregate_type)
  end
end