class Series::ParticipationRows::BaseDecorator < ApplicationDecorator
  decorates_association :round
  decorates_association :entity

  def participation_for_cup(cup)
    object.participation_for_cup(cup).try(:decorate)
  end

  def second_best_time
    calculate_second_time(best_time)
  end

  def second_sum_time
    calculate_second_time(sum_time)
  end
end