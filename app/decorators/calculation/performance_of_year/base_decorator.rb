class Calculation::PerformanceOfYear::BaseDecorator < AppDecorator
  decorates_association :scores
  decorates_association :entity

  def second_valid_time_average
    calculate_second_time(valid_time_average)
  end

  def rounded_points
    points.round
  end
end
