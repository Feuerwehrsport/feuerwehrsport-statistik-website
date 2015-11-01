module Calculation
  class CompetitionsScoreOverview < Struct.new(:competition_ids)
    def years
      @years ||= Year.all
    end

    def disciplines
      [
        DisciplineOverview.new(:hb, :female, competition_ids, years),
        DisciplineOverview.new(:hb, :male, competition_ids, years),
        DisciplineOverview.new(:hl, :female, competition_ids, years),
        DisciplineOverview.new(:hl, :male, competition_ids, years),
        DisciplineOverview.new(:gs, :female, competition_ids, years),
        DisciplineOverview.new(:la, :female, competition_ids, years),
        DisciplineOverview.new(:la, :male, competition_ids, years),
        DisciplineOverview.new(:fs, :female, competition_ids, years),
        DisciplineOverview.new(:fs, :male, competition_ids, years),
      ].each(&:types).reject { |discipline| discipline.types.count == 0 }
    end

    class DisciplineOverview < Struct.new(:discipline, :gender, :competition_ids, :all_years)
      def types
        @scores ||= generate_types
      end

      def generate_types
        types = Discipline.group?(discipline) ? group_score_types : single_score_types
        types.reject { |type| type.count == 0 }
      end

      def single_score_types
        scores = Score.where(competition: competition_ids).german.discipline(discipline).gender(gender)
        [ TypeOverview.new(nil, scores, all_years) ]
      end

      def group_score_types
        GroupScoreType.where(discipline: discipline).map do |group_score_type|
          scores = GroupScore.
            joins(:group_score_category).
            where(group_score_categories: { competition_id: competition_ids, group_score_type_id: group_score_type.id }).
            gender(gender)
          TypeOverview.new(group_score_type.decorate, scores, all_years)
        end
      end
    end

    class TypeOverview < Struct.new(:type, :scores, :all_years)
      attr_reader :count, :average, :best, :years

      def initialize(*args)
        super
        years = {}
        all_years.each do |year|
          best = scores.year(year).valid.order(:time).limit(1).first.try(:decorate)
          years[year.decorate] = best if best.present?
        end
        
        @count = scores.count
        @average = scores.valid.average(:time)
        @best = scores.valid.order(:time).limit(1).first.try(:decorate)
        @years = years
      end
    end
  end
end