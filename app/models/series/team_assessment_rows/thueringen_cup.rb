module Series
  module TeamAssessmentRows
    class ThueringenCup < LaCup
      def <=> other
        compare = other.points <=> points
        return compare if compare != 0
        compare = best_rank <=> other.best_rank
        return compare if compare != 0
        compare = other.best_rank_count <=> best_rank_count
        return compare if compare != 0
        compare = other.ordered_participations.count <=> ordered_participations.count
        return compare if compare != 0
        sum_time <=> other.sum_time
      end

      protected

      def best_rank
        @cups.values.flatten.map(&:rank).min
      end

      def best_rank_count
        @cups.values.flatten.map(&:rank).select { |r| r == best_rank }.count
      end

      def sum_time
        @sum_time ||= begin
          sum = ordered_participations.map(&:time).sum
          if sum >= TimeInvalid::INVALID
            TimeInvalid::INVALID
          else
            sum
          end
        end
      end

      def calc_participation_count
        4
      end
    end
  end
end