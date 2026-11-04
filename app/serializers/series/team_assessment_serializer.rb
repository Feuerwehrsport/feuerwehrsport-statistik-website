# frozen_string_literal: true

class Series::TeamAssessmentSerializer < ApplicationSerializer
  attributes :id, :key, :discipline, :round_id, :name

  def name
    object.config.name
  end
end
