module CompReg
  class TeamDecorator < ApplicationDecorator
    decorates_association :competition
    decorates_association :team_assessment_participations

    def to_s
      name
    end

    def with_number
      "#{name} #{team_number}"
    end
  end
end