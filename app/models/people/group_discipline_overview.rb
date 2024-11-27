# frozen_string_literal: true

TeamMate = Struct.new(:person, :scores)
People::GroupDisciplineOverview = Struct.new(:person, :discipline) do
  def self.for(person)
    %i[gs fs la].map { |discipline| new(person, discipline) }.compact_blank
  end

  delegate :blank?, to: :scores

  def scores
    @scores ||= person.group_score_participations.where(discipline:)
  end

  def scores_decorated
    @scores_decorated ||= scores.includes(competition: %i[place event]).includes(:group_score_type).decorate
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
      TeamMate.new(Person.find(person_id).decorate, scores)
    end
  end

  def best_time
    scores_decorated.min_by { |score| score.object.time }&.second_time
  end

  def average_time
    Firesport::Time.second_time(valid_scores.sum(&:time).to_f / valid_scores.size)
  end
end
