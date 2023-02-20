# frozen_string_literal: true

class Years::InprovementItemDecorator < AppDecorator
  decorates_association :person
  decorates_association :current_scores
  decorates_association :last_scores

  def second_difference
    Firesport::Time.second_time(difference)
  end

  def second_current_average
    Firesport::Time.second_time(current_average)
  end

  def second_last_average
    Firesport::Time.second_time(last_average)
  end
end
