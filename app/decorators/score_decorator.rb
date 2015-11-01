class ScoreDecorator < ApplicationDecorator
  decorates_association :competition
  decorates_association :team
  decorates_association :person

  def entity
    person
  end

  def second_time
    calculate_second_time(time)
  end
end
