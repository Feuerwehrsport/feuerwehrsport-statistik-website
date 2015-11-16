module Series
  class ParticipationDecorator < ApplicationDecorator
    def second_time_with_points
      "#{calculate_second_time(time)} (#{points})"
    end
  end
end
