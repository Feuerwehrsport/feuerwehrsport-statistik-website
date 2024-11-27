# frozen_string_literal: true

People::SingleDisciplineOverview = Struct.new(:person, :single_discipline) do
  def self.for(person)
    SingleDiscipline.gall.map { |sd| new(person, sd) }.compact_blank
  end

  delegate :blank?, to: :scores

  def scores
    @scores ||= person.scores.where(single_discipline:)
  end

  def scores_decorated
    @scores_decorated ||= scores.includes(competition: %i[place event]).decorate
  end

  def chart_scores
    @chart_scores ||= scores.valid.best_of_competition.includes(:competition).decorate.sort_by do |s|
      s.object.competition.date
    end
  end

  def valid_scores
    scores_decorated.map(&:object).reject(&:time_invalid?)
  end

  def count
    scores_decorated.size
  end

  def best_time
    scores_decorated.min_by { |score| score.object.time }&.second_time
  end

  def average_time
    Firesport::Time.second_time(valid_scores.sum(&:time).to_f / valid_scores.size)
  end
end
