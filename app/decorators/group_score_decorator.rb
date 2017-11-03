class GroupScoreDecorator < AppDecorator
  decorates_association :competition
  decorates_association :team
  decorates_association :group_score_category

  def entity
    team
  end

  delegate :discipline, to: :group_score_category, allow_nil: true

  def to_s
    "#{team} #{team_number} - #{second_time}"
  end

  def second_time
    Firesport::Time.second_time(time)
  end

  def translated_discipline_name
    discipline_name(discipline)
  end
end
