# frozen_string_literal: true

class Series::TeamAssessmentSerializer < ActiveModel::Serializer
  attributes :id, :key, :discipline, :round_id
end
