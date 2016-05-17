module Import
  module Series
    class ThueringenCup < LaBase

      protected

      def points
        {
          team: 10,
        }
      end

      def decrement_points(points, rank)
        points -= 1 if rank.in? [2, 3]
        points -= 1 if points > 0
        points
      end
    end
  end
end