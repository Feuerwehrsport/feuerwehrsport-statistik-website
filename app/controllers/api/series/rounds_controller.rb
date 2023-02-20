# frozen_string_literal: true

class API::Series::RoundsController < API::BaseController
  api_actions :create, :show, :index, :update,
              change_log: true,
              default_form: %i[name slug year official aggregate_type full_cup_count]
end
