class API::NationsController < API::BaseController
  api_actions :show, :index, change_log: true
end