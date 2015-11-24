module Backend
  class TeamsController < ResourcesController
    protected

    def permitted_attributes
      super.permit(:name, :shortcut, :status, :latitude, :longitude, :image, :state)
    end
  end
end