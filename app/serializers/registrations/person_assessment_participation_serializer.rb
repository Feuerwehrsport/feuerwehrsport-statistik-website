class Registrations::PersonAssessmentParticipationSerializer < ActiveModel::Serializer
  attributes :assessment_id, :single_competitor_order, :group_competitor_order, :assessment_type

  def assessment_id
    object.competition_assessment_id
  end
end
