module API
  class ScoresController < BaseController
    include CRUD::ShowAction
    include CRUD::UpdateAction
    include CRUD::ChangeLogSupport

    protected

    def update_permitted_attributes
      permitted_attributes.permit(:team_id, :team_number)
    end
  end
end
