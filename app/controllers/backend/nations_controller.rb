module Backend
  class NationsController < ResourcesController
    protected

    def permitted_attributes
      super.permit(:name, :iso)
    end
  end
end