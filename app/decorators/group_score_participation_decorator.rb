# frozen_string_literal: true

class GroupScoreParticipationDecorator < AppDecorator
  decorates_association :competition
  decorates_association :team
  decorates_association :group_score_type

  def second_time
    Firesport::Time.second_time(time)
  end
end
