module Calculation
  class CompetitionsScoreOverview < Struct.new(:competitions)
    def disciplines
      ds = {}

      Score.yearly_best(competitions).decorate.each do |score|
        ds[score.discipline] ||= {}
        ds[score.discipline][score.person.gender] ||= DisciplineOverview.new(score.discipline, score.person.gender, competitions)
        ds[score.discipline][score.person.gender].edit_types.years[score.competition.year] ||= []
        ds[score.discipline][score.person.gender].edit_types.years[score.competition.year].push(score)
      end

      GroupScore.yearly_best(competitions).decorate.each do |score|
        discipline = score.group_score_category.group_score_type.discipline
        ds[discipline] ||= {}
        ds[discipline][score.gender] ||= DisciplineOverview.new(discipline, score.gender, competitions)
        ds[discipline][score.gender].edit_types(score.group_score_category.group_score_type).years[score.group_score_category.competition.year] ||= []
        ds[discipline][score.gender].edit_types(score.group_score_category.group_score_type).years[score.group_score_category.competition.year].push(score)
      end
      ds
    end

    class DisciplineOverview < Struct.new(:discipline, :gender, :competitions)
      attr_reader :types

      def edit_types(type=nil)
        @types ||= {}
        @types[type.to_param] ||= TypeOverview.new(scores_relation(type), type)
      end

      def scores_relation(type)
        Discipline.group?(discipline.to_sym) ? group_scores_relations(type) : single_scores_relations
      end

      def single_scores_relations
        Score
          .where(competition: competitions)
          .german
          .discipline(discipline)
          .gender(gender)
      end

      def group_scores_relations(type)
        GroupScore
          .joins(:group_score_category)
          .where(group_score_categories: { competition_id: competitions, group_score_type_id: type.id })
          .gender(gender)
      end
    end

    class TypeOverview
      attr_reader :count, :average, :best, :years, :type

      def initialize(scores, type)
        @type = type
        @count = scores.count
        @average = scores.valid.average(:time)
        @best = scores.valid.order(:time).limit(1).first.try(:decorate)
        @years = {}
      end
    end
  end
end