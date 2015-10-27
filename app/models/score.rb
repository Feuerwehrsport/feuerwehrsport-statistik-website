class Score < ActiveRecord::Base
  INVALID = 99999999

  belongs_to :person
  belongs_to :competition
  belongs_to :team

  validates :person, :competition, :discipline, :time, :team_number, presence: true

  scope :gender, -> (gender) { joins(:person).merge(Person.gender(gender)) }
  scope :valid, -> { where.not(time: INVALID) }
  scope :hl, -> { where(discipline: "hl") }
  scope :hb, -> { where(discipline: "hb") }
  scope :no_finals, -> { where("team_number >= 0") }
  scope :best_of_competition, -> do
    distinct_column = "CONCAT(#{table_name}.competition_id, '-', #{table_name}.person_id, #{table_name}.discipline)"
    select("DISTINCT ON (#{distinct_column}) #{table_name}.*").order("#{distinct_column}, #{table_name}.time")
  end

  def invalid?
    time == INVALID
  end
end