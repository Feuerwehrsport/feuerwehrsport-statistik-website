module Series
  module TeamAssessmentRows
    class LaCup < Base
      def points
        @points ||= ordered_participations.map(&:points).sum
      end

      def <=> other
        compare = other.points <=> points
        return compare if compare != 0
        best_time_without_nil <=> other.best_time_without_nil
      end

      protected

      def ordered_participations
        @ordered_participations ||= @cups.values.map(&:first).sort do |a, b|
          compare = b.points <=> a.points
          compare == 0 ? a.time <=> b.time : compare
        end.first(3)
      end
    end
  end
end