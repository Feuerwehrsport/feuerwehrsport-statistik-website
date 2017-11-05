class API::PlacesController < API::BaseController
  api_actions :create, :show, :index, :update,
              change_log: true,
              create_form: [:name],
              update_form: %i[latitude longitude]
end
