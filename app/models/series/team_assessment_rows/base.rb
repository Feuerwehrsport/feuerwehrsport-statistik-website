module Series
  module TeamAssessmentRows
    class Base < Struct.new(:team, :team_number)
      include Draper::Decoratable
      attr_reader :participations, :rank

      def add_participation(participation)
        @cups ||= {}
        @cups[participation.cup_id] ||= []
        @cups[participation.cup_id].push(participation)
      end

      def participations_for_cup(cup)
        @cups ||= {}
        @cups[cup.id] || []
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
        @cups.map { |cup| points_for_cup(cup) }.sum
      end

      def best_time
        @best_time ||= begin
          @cups.values.flatten.select { |p| p.assessment.discipline == "la" }.map(&:time).min
        end
      end

      def <=> other
        other.points <=> points
      end
    end
  end
end