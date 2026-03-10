# frozen_string_literal: true

class Series::TeamAssessment < ApplicationRecord
  include Caching::Keys

  belongs_to :round, class_name: 'Series::Round'
  has_many :cups, through: :round, class_name: 'Series::Cup'
  has_many :team_participations, class_name: 'Series::TeamParticipation', dependent: :destroy

  scope :round, ->(round_id) { where(round_id:) }

  schema_validations

  def config
    round.team_assessments_configs.find { |c| c.key == key }
  end
end
