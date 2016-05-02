class ScoreDecorator < ApplicationDecorator
  include Indexable
  index_columns :id, :person, :competition, :second_time, :discipline

  decorates_association :competition
  decorates_association :team
  decorates_association :person

  def entity
    person
  end

  def to_s
    "#{person} - #{second_time}"
  end

  def second_time
    calculate_second_time(time)
  end

  def translated_discipline_name
    discipline_name(discipline)
  end

  def <=>(other)
    object.<=>(other)
  end
end
