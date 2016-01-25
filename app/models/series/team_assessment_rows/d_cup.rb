module Series
  module TeamAssessmentRows
    class DCup < Base
      def self.single_honor_rank
        10
      end

      def <=> other
        compare = other.points <=> points
        return compare if compare != 0
        best_time_without_nil <=> other.best_time_without_nil
      end
    end
  end
end