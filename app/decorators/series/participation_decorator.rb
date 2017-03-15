class Series::ParticipationDecorator < ApplicationDecorator
  def second_time_with_points
    "#{second_time} (#{points})"
  end

  def second_time
    calculate_second_time(time)
  end
end