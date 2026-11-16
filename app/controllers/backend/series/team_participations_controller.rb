# frozen_string_literal: true

class Backend::Series::TeamParticipationsController < Backend::BackendController
  include Backend::Series::ParticipationActions

  private

  def model_class = Series::TeamParticipation
  def serializer = Series::TeamParticipationSerializer
  def new_attributes = { team_number: 1 }
  def permitted_attributes = %i[team_assessment_id team_id team_number team_gender rank points time]
end
