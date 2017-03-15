class API::ScoresController < API::BaseController
  include API::CRUD::ShowAction
  include API::CRUD::UpdateAction
  include API::CRUD::ChangeLogSupport

  protected

  def update_permitted_attributes
    permitted_attributes.permit(:team_id, :team_number)
  end
end