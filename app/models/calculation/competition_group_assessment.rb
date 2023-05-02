# frozen_string_literal: true

Calculation::CompetitionGroupAssessment = Struct.new(:team, :team_number, :competition, :gender) do
  include Draper::Decoratable
  def add_score(score)
    @unsorted_scores ||= []
    @unsorted_scores.push(score)
  end

  delegate :id, to: :team, prefix: true

  def scores
    @scores ||= @unsorted_scores.sort
  end

  def score_in_assessment(score_count = nil)
    score_count ||= competition_score_count
    @score_in_assessment ||= {}
    @score_in_assessment[score_count] = scores.first(score_count)
  end

  def score_out_assessment(score_count = nil)
    score_count ||= competition_score_count
    @score_out_assessment ||= {}
    @score_out_assessment[score_count] = scores.drop(score_count)
  end

  def time(score_count = nil)
    score_count ||= competition_score_count
    @time ||= {}
    @time[score_count] ||= calculate_time(score_count)
  end

  def <=>(other)
    time <=> other.time
  end

  protected

  def competition_score_count
    @competition_score_count ||= competition.score_type.score
  end

  def calculate_time(score_count)
    if score_in_assessment(score_count).count(&:time_valid?) < score_count
      Firesport::INVALID_TIME
    else
      score_in_assessment(score_count).sum(&:time)
    end
  end
end
