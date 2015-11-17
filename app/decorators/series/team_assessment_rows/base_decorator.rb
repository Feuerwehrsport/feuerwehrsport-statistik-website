module Series
  module TeamAssessmentRows
    class BaseDecorator < ApplicationDecorator
      decorates_association :team

      def participations_for_cup(cup)
        object.participations_for_cup(cup).map(&:decorate)
      end

      def second_best_time
        calculate_second_time(best_time)
      end
    end
  end
end
