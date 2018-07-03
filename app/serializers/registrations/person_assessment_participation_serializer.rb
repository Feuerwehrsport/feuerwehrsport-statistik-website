class Registrations::PersonAssessmentParticipationSerializer < ActiveModel::Serializer
  attributes :assessment_id, :single_competitor_order, :group_competitor_order, :competitor_order, :assessment_type

  delegate :assessment_id, to: :object
end
