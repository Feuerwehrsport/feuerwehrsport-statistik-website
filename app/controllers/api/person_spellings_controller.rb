# frozen_string_literal: true

class Api::PersonSpellingsController < Api::BaseController
  api_actions :index,
              change_log: true
end
