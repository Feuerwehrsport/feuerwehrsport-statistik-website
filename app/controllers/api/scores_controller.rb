# frozen_string_literal: true

class API::ScoresController < API::BaseController
  api_actions :show, :index, :update,
              change_log: true,
              update_form: %i[team_id team_number]
end
