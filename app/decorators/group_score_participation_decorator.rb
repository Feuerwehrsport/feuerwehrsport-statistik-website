class GroupScoreParticipationDecorator < AppDecorator
  decorates_association :competition
  decorates_association :team
  decorates_association :group_score_type

  def second_time
    calculate_second_time(time)
  end
end
