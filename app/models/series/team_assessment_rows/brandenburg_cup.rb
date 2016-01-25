module Series
  module TeamAssessmentRows
    class BrandenburgCup < Base
      def <=> other
        compare = other.points <=> points
        return compare if compare != 0
        compare = other.participation_count <=> participation_count
        return compare if compare != 0
        sum_time <=> other.sum_time
      end

      def calculate_rank!(other_rows)
        current_rank = 0
        other_rows.each do |rank_row|
          if rank_row.participation_count < 3
            return @rank = nil if rank_row == self
            next
          end
          current_rank += 1
          if 0 == (self <=> rank_row)
            return @rank = current_rank
          end
        end
      end

      def participation_count
        @cups.values.count
      end

      protected

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
    end
  end
end