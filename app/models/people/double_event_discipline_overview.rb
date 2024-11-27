# frozen_string_literal: true

People::DoubleEventDisciplineOverview = Struct.new(:person, :hb_id, :hl_id, :scores) do
  def self.for(person)
    events = ScoreDoubleEvent.where(person_id: person.id).includes(competition: %i[place event]).to_a
    events.group_by { |d| [d.hb_single_discipline_id, d.hl_single_discipline_id] }.sort.map do |sd_ids, scores|
      new(person, sd_ids[0], sd_ids[1], scores)
    end
  end

  def scores_decorated
    @scores_decorated ||= scores.map(&:decorate)
  end

  def chart_scores
    @chart_scores ||= scores_decorated.sort_by { |s| s.object.competition.date }
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
