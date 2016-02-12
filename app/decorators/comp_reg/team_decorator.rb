module CompReg
  class TeamDecorator < ApplicationDecorator
    decorates_association :competition
    decorates_association :team_assessment_participations
    decorates_association :admin_user

    def to_s
      name
    end

    def with_number
      "#{name} #{team_number}"
    end
  end
end