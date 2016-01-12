module API
  class EventsController < BaseController
    include CRUD::CreateAction
    include CRUD::ShowAction
    include CRUD::IndexAction
    
    protected

    def create_permitted_attributes
      permitted_attributes.permit(:name)
    end
  end
end
