module Backend
  class PlacesController < ResourcesController
    protected

    def permitted_attributes
      super.permit(:name)
    end
  end
end