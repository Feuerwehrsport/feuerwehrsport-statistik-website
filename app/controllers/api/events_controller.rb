class API::EventsController < API::BaseController
  api_actions :create, :show, :index, change_log: true,
    default_form: [:name]
end
