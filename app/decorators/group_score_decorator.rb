class GroupScoreDecorator < ApplicationDecorator
  decorates_association :competition
  decorates_association :team
  decorates_association :group_score_category

  def entity
    team
  end

  def second_time
    calculate_second_time(time)
  end
end
