# frozen_string_literal: true

class Series::PersonAssessmentSerializer < ActiveModel::Serializer
  attributes :id, :key, :discipline, :round_id
end
