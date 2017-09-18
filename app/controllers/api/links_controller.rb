class API::LinksController < API::BaseController
  api_actions :create, :show, :destroy, change_log: true, 
    default_form: [:label, :url, :linkable_type, :linkable_id]
end