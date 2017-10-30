class Registrations::TeamAssessmentParticipation < Registrations::AssessmentParticipation
  belongs_to :team, class_name: 'Registrations::Team'

  validates :team, presence: true
end
