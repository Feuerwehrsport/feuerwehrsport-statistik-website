module CompReg
  class TeamDecorator < ApplicationDecorator
    decorates_association :competition
    decorates_association :team_assessment_participations
  end
end