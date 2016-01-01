module Calculation
  module PerformanceOfYear
    class Base
      include Draper::Decoratable
      attr_reader :scores, :entity
      attr_accessor :rank

      def initialize(entity)
        @entity = entity
        @scores = []
      end

      def valid_times
        @valid_times ||= scores.reject(&:time_invalid?)
      end

      def valid_time_sum
        valid_times.map(&:time).sum
      end

      def valid_time_count
        valid_times.count
      end

      def invalid_time_count
        scores.to_a.count - valid_time_count
      end

      def valid_time_average
        @valid_time_average ||= valid_time_count > 0 ? valid_time_sum/valid_time_count : TimeInvalid::INVALID
      end

      def points
        @points ||= begin
          # - 1/23 *x^2+ 10
          sum = 0
          (0..valid_time_count-1).each do |z|
            subtotal = -1.0/23.0 * (z ** 2) + 10
            break if subtotal < 0
            sum += subtotal
          end

          valid_time_average + invalid_time_count * 15 - sum
        end
      end

      def self.entries(year, discipline, gender)
        Caching::Cache.fetch("performance_of_year-#{year}-#{discipline}-#{gender}") do
          entries = {}
          score_collection.gender(gender).discipline(discipline).year(year).each do |score|
            entries[score.entity_id] ||= new(score.entity)
            entries[score.entity_id].scores.push(score)
          end

          entries.values.sort_by(&:points).each_with_index { |e, i| e.rank = i + 1 }
        end
      end
    end
  end
end