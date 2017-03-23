class CompReg::TeamAssessmentParticipation < CompReg::AssessmentParticipation
  belongs_to :team, class_name: 'CompReg::Team'

  validates :team, presence: true
end
