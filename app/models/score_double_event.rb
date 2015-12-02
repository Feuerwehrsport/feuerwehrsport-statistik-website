class ScoreDoubleEvent < ActiveRecord::View
  belongs_to :competition
  belongs_to :person

  scope :gender, -> (gender) { joins(:person).merge(Person.gender(gender)) }

  def time_invalid?
    false
  end
end
