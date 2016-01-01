module API
  class PlacesController < BaseController
    include CRUD::IndexAction
    include CRUD::UpdateAction

    def update_permitted_attributes
      permitted_attributes.permit(:latitude, :longitude)
    end
  end
end
