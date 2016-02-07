module CompReg
  class TeamAssessmentParticipation < AssessmentParticipation
    belongs_to :team

    validates :team, presence: true
  end
end
