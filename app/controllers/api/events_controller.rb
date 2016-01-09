module API
  class EventsController < BaseController
    include CRUD::ShowAction
    include CRUD::IndexAction
  end
end
