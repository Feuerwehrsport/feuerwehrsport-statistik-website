module API
  class PlacesController < BaseController
    include CRUD::CreateAction
    include CRUD::ShowAction
    include CRUD::IndexAction
    include CRUD::UpdateAction

    protected

    def create_permitted_attributes
      permitted_attributes.permit(:name)
    end

    def update_permitted_attributes
      permitted_attributes.permit(:latitude, :longitude)
    end
  end
end
