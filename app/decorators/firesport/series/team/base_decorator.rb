# frozen_string_literal: true

class Firesport::Series::Team::BaseDecorator < AppDecorator
  decorates_association :team

  def participations_for_cup(cup)
    object.participations_for_cup(cup).map(&:decorate)
  end

  def second_best_time
    Firesport::Time.second_time(best_time)
  end
end
