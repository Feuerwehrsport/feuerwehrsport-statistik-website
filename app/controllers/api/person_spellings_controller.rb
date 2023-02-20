# frozen_string_literal: true

class API::PersonSpellingsController < API::BaseController
  api_actions :index,
              change_log: true
end
