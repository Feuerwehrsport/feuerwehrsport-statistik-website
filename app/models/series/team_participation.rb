# frozen_string_literal: true

class Series::TeamParticipation < ApplicationRecord
  include Firesport::TimeInvalid

  belongs_to :cup, class_name: 'Series::Cup'
  belongs_to :team_assessment, class_name: 'Series::TeamAssessment'
  belongs_to :team, class_name: '::Team'

  schema_validations

  def points_with_correction
    points + (points_correction || 0)
  end

  def entity_id
    "#{team_id}-#{team_number}"
  end
end
