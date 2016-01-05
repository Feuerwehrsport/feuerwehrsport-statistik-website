module Series
  module ParticipationRows
    class MVCup < Base
      def sum_time
        @sum_time ||= ordered_participations.map(&:time).sum
      end

      def points
        @points ||= ordered_participations.map(&:points).sum
      end

      def <=> other
        compare = other.max_count <=> max_count 
        return compare if compare != 0
        compare = other.points <=> points
        return compare if compare != 0
        compare = sum_time <=> other.sum_time
        return compare if compare != 0
        best_time <=> other.best_time
      end

      def max_count
        @max_count ||= [count, 3].min
      end

      protected

      def ordered_participations
        @ordered_participations ||= @participations.sort do |a, b|
          compare = b.points <=> a.points
          compare == 0 ? a.time <=> b.time : compare
        end.first(3)
      end
    end
  end
end