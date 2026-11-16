# frozen_string_literal: true

class Backend::Series::PersonParticipationsController < Backend::BackendController
  include Backend::Series::ParticipationActions

  private

  def model_class = Series::PersonParticipation
  def serializer = Series::PersonParticipationSerializer
  def new_attributes = { person_assessment_id: params[:person_assessment_id] }
  def permitted_attributes = %i[person_assessment_id person_id rank points time]
end
