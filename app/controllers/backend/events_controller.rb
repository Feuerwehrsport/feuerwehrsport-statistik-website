module Backend
  class EventsController < ResourcesController
    protected

    def permitted_attributes
      super.permit(:name)
    end
  end
end