module Series
  module TeamAssessmentRows
    class Base < Struct.new(:team, :team_number)
      include Draper::Decoratable
      attr_reader :rank

      def initialize(*args)
        super(*args)
        @rank = 0
      end

      def self.honor_rank
        3
      end

      def self.single_honor_rank
        3
      end

      def team_id
        team.id
      end

      def add_participation(participation)
        @cups ||= {}
        @cups[participation.cup_id] ||= []
        @cups[participation.cup_id].push(participation)
      end

      def participations_for_cup(cup)
        @cups ||= {}
        (@cups[cup.id] || []).sort_by(&:assessment)
      end

      def points_for_cup(cup)
        @cups ||= {}
        @cups[cup.id] ||= []
        @cups[cup.id].map(&:points).sum
      end

      def count
        @cups ||= {}
        @cups.values.count
      end

      def points
        @cups.values.map { |cup| cup.map(&:points).sum }.sum
      end

      def best_time
        @best_time ||= begin
          @cups.values.flatten.select { |p| p.assessment.discipline == "la" }.map(&:time).min
        end
      end

      def best_time_without_nil
        best_time || (TimeInvalid::INVALID + 1)
      end

      def <=> other
        other.points <=> points
      end

      def self.special_sort!(rows)
      end 

      def calculate_rank!(other_rows)
        other_rows.each_with_index do |rank_row, rank|
          if 0 == (self <=> rank_row)
            return @rank = (rank + 1)
          end
        end
      end
    end
  end
end