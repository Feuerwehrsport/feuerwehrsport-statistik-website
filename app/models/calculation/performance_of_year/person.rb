module Calculation
  module PerformanceOfYear
    class Person < Base
      def person
        entity
      end

      def self.score_collection
        Score.german.includes(competition: %i[event place]).includes(:person)
      end
    end
  end
end
