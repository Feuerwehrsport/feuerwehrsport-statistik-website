module Import
  module Series
    class BrandenburgCup < LaBase

      protected

      def points
        {
          team: 11,
        }
      end

      def decrement_points(points, rank)
        points -= 1 if rank == 2
        points -= 1 if points > 0
        points
      end
    end
  end
end