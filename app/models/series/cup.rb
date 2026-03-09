# frozen_string_literal: true

class Series::Cup < ApplicationRecord
  include Series::Participationable

  belongs_to :round, class_name: 'Series::Round'
  belongs_to :competition, class_name: 'Competition'
  has_many :team_assessments, through: :round, class_name: 'Series::TeamAssessment'
  has_many :person_assessments, through: :round, class_name: 'Series::PersonAssessment'
  has_many :team_participations, dependent: :destroy, class_name: 'Series::TeamParticipation'
  has_many :person_participations, dependent: :destroy, class_name: 'Series::PersonParticipation'

  default_scope -> { joins(:competition).order(Arel.sql('competitions.date')) }
  schema_validations
end
