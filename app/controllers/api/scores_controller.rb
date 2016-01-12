module API
  class ScoresController < BaseController
    include CRUD::UpdateAction

    protected

    def update_permitted_attributes
      permitted_attributes.permit(:team_id)
    end
  end
end
