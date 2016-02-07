module CompReg
  class PersonAssessmentParticipation < AssessmentParticipation
    belongs_to :person

    validates :person, presence: true
  end
end
