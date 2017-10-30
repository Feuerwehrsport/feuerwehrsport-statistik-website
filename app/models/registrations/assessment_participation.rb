class Registrations::AssessmentParticipation < ActiveRecord::Base
  belongs_to :competition_assessment, class_name: 'Registrations::CompetitionAssessment'

  validates :competition_assessment, presence: true
end
