class Calculation::CompetitionGroupAssessmentDecorator < ApplicationDecorator
  decorates_association :score_in_assessment
  decorates_association :score_out_assessment
  decorates_association :scores

  def second_time
    calculate_second_time(time)
  end
end
