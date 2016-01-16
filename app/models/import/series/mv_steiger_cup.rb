module Import
  module Series
    class MVSteigerCup < MVSingleCup

      protected

      def assessment_disciplines
        {
          person: { hl: [""] },
          team: {},
          group: {},
        }
      end
    end
  end
end