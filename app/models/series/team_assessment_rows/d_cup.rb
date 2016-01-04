module Series
  module TeamAssessmentRows
    class DCup < Base
      def <=> other
        compare = other.points <=> points
        return compare if compare != 0
        best_time <=> other.best_time
      end
    end
  end
end