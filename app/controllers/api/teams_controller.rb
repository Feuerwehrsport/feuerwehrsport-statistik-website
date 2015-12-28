module API
  class TeamsController < BaseController
    include CRUD::CreateAction
    include CRUD::ShowAction
    include CRUD::UpdateAction
    include CRUD::IndexAction

    protected

    def create_permitted_attributes
      permitted_attributes.permit(:name, :shortcut, :status)
    end

    def update_permitted_attributes
      permitted_attributes.permit(:latitude, :longitude)
    end
  end
end
