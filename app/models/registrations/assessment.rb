# frozen_string_literal: true

class Registrations::Assessment < ApplicationRecord
  belongs_to :band, class_name: 'Registrations::Band', inverse_of: :assessments
  has_many :assessment_participations, dependent: :destroy, class_name: 'Registrations::AssessmentParticipation',
                                       inverse_of: :assessment
  delegate :competition, to: :band

  default_scope { order(:name, :discipline) }
  scope :requestable_for, ->(entity) do
    all_disciplines = where(band_id: entity.band_id)
    all_disciplines = all_disciplines.for_teams if entity.is_a?(Registrations::Team)
    all_disciplines = all_disciplines.for_people if entity.is_a?(Registrations::Person) && entity.team.nil?
    all_disciplines
  end

  scope :for_people, -> { where.not(discipline: Discipline::GROUP) }
  scope :for_teams, -> { where(discipline: Discipline::GROUP) }
end
