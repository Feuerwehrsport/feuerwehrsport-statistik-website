class GroupScoreDecorator < ApplicationDecorator
  include Indexable
  index_columns :id, :team, :team_number, :translated_gender, :competition, :discipline, :second_time

  decorates_association :competition
  decorates_association :team
  decorates_association :group_score_category

  def entity
    team
  end

  def discipline
    group_score_category.discipline
  end

  def to_s
    "#{team} #{team_number + 1} - #{second_time}"
  end

  def second_time
    calculate_second_time(time)
  end

  def translated_discipline_name
    discipline_name(discipline)
  end
end
