module CompReg
  class PersonAssessmentParticipation < AssessmentParticipation
    belongs_to :person

    validates :person, :single_competitor_order, presence: true
  end
end
