module CompReg
  class CompetitionAssessment < ActiveRecord::Base
    include Genderable
    belongs_to :competition

    validates :competition, :discipline, :gender, presence: true
  end
end
