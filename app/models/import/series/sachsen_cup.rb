module Import
  module Series
    class SachsenCup < LaBase

      protected

      def points
        {
          team: 10,
        }
      end

      def decrement_points(points, rank)
        if round.year.to_i < 2015
          points -= 1 if rank < 4
          points -= 1 if points > 0
          points
        else
          super
        end
      end
    end
  end
end