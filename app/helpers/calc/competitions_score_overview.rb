# frozen_string_literal: true

class Calc::CompetitionsScoreOverview < Calc::Base
  attr_accessor :competitions

  def disciplines
    ds = {}

    SingleDiscipline.gall.map(&:decorate).each do |single_discipline|
      Score.yearly_best(competition_ids, single_discipline).decorate.each do |score|
        key = single_discipline.key
        gender = score.person.gender

        ds[key] ||= {}
        ds[key][gender] ||= DisciplineOverview.new(key, gender, competition_ids)
        ds[key][gender].add_score(single_discipline, score.competition.year, score)
      end
    end

    GroupScore.yearly_best(competition_ids).decorate.each do |score|
      key = score.group_score_category.group_score_type.discipline
      gender = score.gender
      year = score.group_score_category.competition.year

      ds[key] ||= {}
      ds[key][gender] ||= DisciplineOverview.new(key, gender, competition_ids)
      ds[key][gender].add_score(score.group_score_category.group_score_type, year, score)
    end
    ds
  end

  def competition_ids
    @competition_ids ||= competitions.map(&:id)
  end

  DisciplineOverview = Struct.new(:key, :gender, :competition_ids) do
    attr_reader :types

    def add_score(type, year, score)
      @types ||= {}
      @types[type.to_param] ||= TypeOverview.new(scores_relation(type), type)
      @types[type.to_param].years[year] ||= []
      @types[type.to_param].years[year].push(score)
    end

    def scores_relation(type)
      Discipline.group?(key.to_sym) ? group_scores_relations(type) : single_scores_relations(type)
    end

    def single_scores_relations(sd)
      Score
        .where(competition: competition_ids, single_discipline: sd)
        .german
        .gender(gender)
    end

    def group_scores_relations(type)
      GroupScore
        .joins(:group_score_category)
        .where(group_score_categories: { competition_id: competition_ids, group_score_type_id: type.id })
        .gender(gender)
    end
  end

  class TypeOverview
    attr_reader :count, :average, :best, :years, :type

    def initialize(scores, type)
      @type = type
      @count = scores.count
      @average = scores.valid.average(:time)
      @best = scores.valid.order(:time).limit(1).first&.decorate
      @years = {}
    end
  end
end
