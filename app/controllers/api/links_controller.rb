class API::LinksController < API::BaseController
  api_actions :create, :show, :destroy,
              change_log: true,
              default_form: %i[label url linkable_type linkable_id]
end
