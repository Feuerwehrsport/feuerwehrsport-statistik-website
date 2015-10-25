class ScoreDecorator < ApplicationDecorator
  decorates_association :competition
  decorates_association :team

  def second_time
    calculate_second_time(time)
  end
end
