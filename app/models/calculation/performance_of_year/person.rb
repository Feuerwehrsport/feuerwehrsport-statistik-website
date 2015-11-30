module Calculation
  module PerformanceOfYear
    class Person < Base
      def person
        entity
      end

      def self.score_collection
        Score.german.includes(competition: [:event, :place]).includes(:person)
      end
    end
  end
end