module Series
  module TeamAssessmentRows
    class SachsenSteigerCup < Base
      def <=> other
        compare = other.points <=> points
        return compare if compare != 0
        compare = sum_time <=> other.sum_time
        return compare if compare != 0
        best_time <=> other.best_time
      end

      def sum_time
        @sum_time ||= begin
          sum = @cups.values.flatten.map(&:time).sum
          if sum >= TimeInvalid::INVALID
            TimeInvalid::INVALID
          else
            sum
          end
        end
      end

      def best_time
        @best_time ||= begin
          @cups.values.flatten.reject(&:time_invalid?).map(&:time).sort.first || TimeInvalid::INVALID
        end
      end
    end
  end
end