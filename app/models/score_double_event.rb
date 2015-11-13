class ScoreDoubleEvent < ActiveRecord::Base
  belongs_to :competition
  belongs_to :person

  scope :gender, -> (gender) { joins(:person).merge(Person.gender(gender)) }

  def invalid?
    false
  end

  protected

  def readonly?
    true
  end
end
