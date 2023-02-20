# frozen_string_literal: true

People::DisciplineOverview = Struct.new(:person, :discipline) do
  def self.for(person)
    %i[hb hw hl zk zw gs fs la].map { |discipline| new(person, discipline) }.reject(&:blank?)
  end

  delegate :blank?, to: :scores

  def scores
    @scores ||= begin
      case discipline
      when :hb, :hw, :hl
        person.scores.where(discipline: discipline)
      when :zk
        person.score_double_events
      when :zw
        person.score_low_double_events
      when :gs, :fs, :la
        person.group_score_participations.where(discipline: discipline)
      end
    end
  end

  def scores_decorated
    @scores_decorated ||= begin
      if discipline.in?(%i[gs fs la])
        scores.includes(competition: %i[place event]).includes(:group_score_type).decorate
      else
        scores.includes(competition: %i[place event]).decorate
      end
    end
  end

  def chart_scores
    @chart_scores ||= begin
      best = discipline.in?(%i[zk zw]) ? scores : scores.valid.best_of_competition
      best.includes(:competition).sort_by { |s| s.competition.date }.map(&:decorate)
    end
  end

  def valid_scores
    scores_decorated.map(&:object).reject(&:time_invalid?)
  end

  def count
    scores_decorated.size
  end

  def team_mates
    team_mates = {}
    person
      .group_scores
      .discipline(discipline)
      .includes(:person_participations)
      .includes(group_score_category: :competition)
      .decorate
      .each do |score|
      score.person_participations.each do |person_participation|
        next if person_participation.person_id == person.id

        team_mates[person_participation.person_id] ||= []
        team_mates[person_participation.person_id].push(score)
      end
    end
    team_mates.map do |person_id, scores|
      OpenStruct.new(person: Person.find(person_id).decorate, scores: scores)
    end
  end

  def best_time
    scores_decorated.min_by { |score| score.object.time }&.second_time
  end

  def average_time
    Firesport::Time.second_time(valid_scores.map(&:time).sum.to_f / valid_scores.size)
  end
end
