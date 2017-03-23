class CompReg::AssessmentParticipation < ActiveRecord::Base
  belongs_to :competition_assessment, class_name: 'CompReg::CompetitionAssessment'

  validates :competition_assessment, presence: true
end
