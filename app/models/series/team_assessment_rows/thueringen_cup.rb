module Series
  module TeamAssessmentRows
    class ThueringenCup < LaCup
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

      def honor_sort other
        compare = other.points <=> points
        return compare if compare != 0
        compare = other.participation_count <=> participation_count
        return compare if compare != 0
        compare = best_rank <=> other.best_rank
        return compare if compare != 0
        compare = other.best_rank_count <=> best_rank_count
        return compare if compare != 0
        sum_time <=> other.sum_time
      end

      def participation_count
        @cups.values.count
      end

      def self.special_sort!(rows)
        honor_rows = rows.select { |row| row.rank.present? && row.rank <= 3 }.sort { |row, other| row.honor_sort(other) }
        honor_rows.each { |row| row.calculate_rank!(honor_rows) }
        rows.sort_by! { |row| row.rank || 999 }
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
          sum = @cups.values.flatten.map(&:time).sum
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