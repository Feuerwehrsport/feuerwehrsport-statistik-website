# frozen_string_literal: true

class Series::ParticipationDecorator < AppDecorator
  def second_time_with_points
    "#{second_time} (#{points})"
  end

  def second_time
    Firesport::Time.second_time(time)
  end
end
