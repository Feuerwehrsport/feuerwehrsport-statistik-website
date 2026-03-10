# frozen_string_literal: true

class Api::Series::PersonParticipationsController < Api::BaseController
  api_actions :create, :show, :index, :update, :destroy,
              change_log: true,
              create_form: %i[cup_id person_assessment_id person_id rank points time],
              update_form: %i[person_assessment_id person_id rank points time]
end
