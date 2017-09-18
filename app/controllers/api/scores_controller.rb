class API::ScoresController < API::BaseController
  api_actions :show, :index, :update, change_log: true, 
    update_form: [:team_id, :team_number]
end