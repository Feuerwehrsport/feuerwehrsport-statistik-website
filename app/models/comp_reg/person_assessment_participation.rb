module CompReg
  class PersonAssessmentParticipation < AssessmentParticipation
    belongs_to :person
    enum assessment_type: { group_competitor: 0, single_competitor: 1, out_of_competition: 2 }

    validates :group_competitor_order, :single_competitor_order, numericality: { greater_than_or_equal_to: 0 }
    validates :person, :assessment_type, presence: true
  end
end
