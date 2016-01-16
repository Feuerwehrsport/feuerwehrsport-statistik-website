module Import
  module Series
    class MVHindernisCup < MVSingleCup

      protected

      def assessment_disciplines
        {
          person: { hb: [""] },
          team: {},
          group: {},
        }
      end
    end
  end
end