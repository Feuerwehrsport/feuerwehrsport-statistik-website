class Registrations::Assessment < ActiveRecord::Base
  include Genderable
  belongs_to :competition, class_name: 'Registrations::Competition', inverse_of: :assessments
  has_many :assessment_participations, dependent: :destroy, class_name: 'Registrations::AssessmentParticipation',
                                       inverse_of: :assessment

  validates :competition, :discipline, :gender, presence: true

  default_scope { order(:name, :discipline, :gender) }
  scope :requestable_for, ->(entity) do
    all_disciplines = where(competition_id: entity.competition_id)
    all_disciplines = all_disciplines.gender(entity.gender) if entity.gender.present?
    all_disciplines = all_disciplines.for_people if entity.is_a?(Registrations::Person)
    all_disciplines = all_disciplines.for_teams if entity.is_a?(Registrations::Team)
    all_disciplines
  end

  scope :requestable_for_person, ->(person) do
    where(competition_id: person.competition_id).gender(person.gender).for_people
  end

  scope :for_people, -> { where.not(discipline: Discipline::GROUP) }
  scope :for_teams, -> { where(discipline: Discipline::GROUP) }
end
