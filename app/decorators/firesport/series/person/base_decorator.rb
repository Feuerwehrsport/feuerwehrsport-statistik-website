class Firesport::Series::Person::BaseDecorator < AppDecorator
  decorates_association :round
  decorates_association :entity

  def participation_for_cup(cup)
    object.participation_for_cup(cup).try(:decorate)
  end

  def second_best_time
    Firesport::Time.second_time(best_time)
  end

  def second_sum_time
    Firesport::Time.second_time(sum_time)
  end
end
