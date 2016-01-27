module CompReg
  class AssessmentParticipation < ActiveRecord::Base
    belongs_to :competition_assessment

    validates :competition_assessment, presence: true
  end
end
