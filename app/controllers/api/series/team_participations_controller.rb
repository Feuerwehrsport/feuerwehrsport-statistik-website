# frozen_string_literal: true

class Api::Series::TeamParticipationsController < Api::BaseController
  api_actions :create, :show, :index, :update, :destroy,
              change_log: true,
              create_form: %i[cup_id team_assessment_id team_id team_number team_gender rank points time],
              update_form: %i[team_assessment_id team_id team_number team_gender rank points time]
end
