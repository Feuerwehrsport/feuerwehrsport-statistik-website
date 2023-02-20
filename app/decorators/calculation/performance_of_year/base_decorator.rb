# frozen_string_literal: true

class Calculation::PerformanceOfYear::BaseDecorator < AppDecorator
  decorates_association :scores
  decorates_association :entity

  def second_valid_time_average
    Firesport::Time.second_time(valid_time_average)
  end

  def rounded_points
    points.round
  end
end
