module Calculation
  module PerformanceOfYear
    class Team < Base
      def team
        entity
      end

      def self.score_collection
        GroupScore.regular.includes(group_score_category: { competition: %i[event place] }).includes(:team)
      end
    end
  end
end
