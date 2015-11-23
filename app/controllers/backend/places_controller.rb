module Backend
  class PlacesController < ResourcesController
    protected

    def permitted_attributes
      super.permit(:name, :latitude, :longitude)
    end
  end
end