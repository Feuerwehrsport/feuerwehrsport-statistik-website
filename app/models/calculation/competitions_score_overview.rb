# frozen_string_literal: true

class Calculation::CompetitionsScoreOverview
  attr_accessor :competitions

  def initialize(competitions)
    self.competitions = competitions
  end

  def disciplines
    ds = {}

    SingleDiscipline.gall.each do |sd|
      sd = sd.decorate
      Score.yearly_best(competitions, sd).decorate.each do |score|
        discipline = sd.key
        gender = score.person.gender
        ds[discipline] ||= {}
        ds[discipline][gender] ||= DisciplineOverview.new(discipline, gender, competitions)
        ds[discipline][gender].edit_types(sd).years[score.competition.year] ||= []
        ds[discipline][gender].edit_types(sd).years[score.competition.year].push(score)
      end
    end

    GroupScore.yearly_best(competitions).decorate.each do |score|
      discipline = score.group_score_category.group_score_type.discipline
      gender = score.gender
      year = score.group_score_category.competition.year
      ds[discipline] ||= {}
      ds[discipline][gender] ||= DisciplineOverview.new(discipline, gender, competitions)
      ds[discipline][gender].edit_types(score.group_score_category.group_score_type).years[year] ||= []
      ds[discipline][gender].edit_types(score.group_score_category.group_score_type).years[year].push(score)
    end
    ds
  end

  DisciplineOverview = Struct.new(:discipline, :gender, :competitions) do
    attr_reader :types

    def edit_types(type = nil)
      @types ||= {}
      @types[type.to_param] ||= TypeOverview.new(scores_relation(type), type)
    end

    def scores_relation(type)
      Discipline.group?(discipline.to_sym) ? group_scores_relations(type) : single_scores_relations(type)
    end

    def single_scores_relations(sd)
      Score
        .where(competition: competitions, single_discipline: sd)
        .german
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
