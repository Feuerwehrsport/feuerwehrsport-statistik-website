class ScoreDoubleEvent < ApplicationRecord
  is_view

  belongs_to :competition
  belongs_to :person

  scope :gender, ->(gender) { joins(:person).merge(Person.gender(gender)) }
  scope :year, ->(year) { joins(:competition).merge(Competition.year(year)) }

  def time_invalid?
    false
  end

  def <=>(other)
    compare = time <=> other.time
    return compare if compare != 0

    keys = person.gender == 'female' ? %i[hb hl] : %i[hl hb]
    keys.each do |key|
      compare = send(key) <=> other.send(key)
      next if compare.zero?

      return compare
    end
    0
  end
end
