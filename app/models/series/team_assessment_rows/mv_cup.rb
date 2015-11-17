module Series
  module TeamAssessmentRows
    class MVCup < Base
      def points
        @points ||= ordered_participations.map(&:points).sum
      end

      def <=> other
        compare = other.points <=> points
        return compare if compare != 0
        best_time <=> other.best_time
      end

      def max_count
        @max_count ||= [count, 3].min
      end

      protected

      def ordered_participations
        @ordered_participations ||= @cups.values.map(&:first).sort do |a, b|
          compare = a.points <=> b.points
          compare == 0 ? a.time <=> b.time : compare
        end.first(3)
      end
    end
  end
end