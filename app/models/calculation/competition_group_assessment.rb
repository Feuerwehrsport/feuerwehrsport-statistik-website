class Calculation::CompetitionGroupAssessment < Struct.new(:team, :team_number, :competition, :gender)
  include Draper::Decoratable
  def add_score(score)
    @scores ||= []
    @scores.push(score)
  end

  def team_id
    team.id
  end

  def scores
    @sorted_scores ||= @scores.sort
  end

  def score_in_assessment
    @score_in_assessment ||= scores.first(competition.score_type.score)
  end

  def score_out_assessment
    @score_out_assessment ||= scores.drop(competition.score_type.score)
  end

  def time
    @time ||= begin
      if score_in_assessment.reject(&:invalid?).count < competition.score_type.score
        Score::INVALID
      else
        score_in_assessment.map(&:time).sum
      end
    end
  end

  def <=>(other)
    time <=> other.time
  end
end