class Calculation::CompetitionGroupAssessmentDecorator < AppDecorator
  decorates_association :score_in_assessment
  decorates_association :score_out_assessment
  decorates_association :scores
  decorates_association :competition

  def second_time
    Firesport::Time.second_time(time)
  end

  def second_time_by_6
    Firesport::Time.second_time(time(6))
  end
end
