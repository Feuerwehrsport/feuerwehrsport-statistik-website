module Calculation
  module PerformanceOfYear
    class BaseDecorator < ApplicationDecorator
      decorates_association :scores
      decorates_association :entity

      def second_valid_time_average
        calculate_second_time(valid_time_average)
      end
    end
  end
end
