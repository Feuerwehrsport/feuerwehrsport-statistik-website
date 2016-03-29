class Score < ActiveRecord::Base
  # 4  = Mannschaft 4
  # 3  = Mannschaft 3
  # 2  = Mannschaft 2
  # 1  = Mannschaft 1
  # 0 = Einzelstarter
  # -1 = Finale
  # -2 = Halbfinale
  # -3 = Viertelfinale
  # -4 = Achtelfinale
  # -5 = Außer der Wertung 

  include TimeInvalid

  belongs_to :person
  belongs_to :competition
  belongs_to :team

  validates :person, :competition, :discipline, :time, :team_number, presence: true

  scope :gender, -> (gender) { joins(:person).merge(Person.gender(gender)) }
  scope :discipline, -> (discipline) { where(discipline: discipline) }
  scope :hl, -> { discipline(:hl) }
  scope :hb, -> { discipline(:hb) }
  scope :no_finals, -> { where("team_number >= 0") }
  scope :out_of_competition, -> { where(team_number: -5) }
  scope :finals, -> (final_number) { where(team_number: final_number) }
  scope :with_team, -> { where.not(team_id: nil) }
  scope :best_of_competition, -> do
    distinct_column = "CONCAT(#{table_name}.competition_id, '-', #{table_name}.person_id, #{table_name}.discipline)"
    select("DISTINCT ON (#{distinct_column}) #{table_name}.*").order("#{distinct_column}, #{table_name}.time")
  end
  scope :german, -> { joins(:person).merge(Person.german) }
  scope :year, -> (year) { joins(:competition).merge(Competition.year(year)) }
  scope :best_of_year, -> (year, discipline, gender) do
    sql = Score.year(year).discipline(discipline).gender(gender).
      select("#{table_name}.*, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY time ) AS r").
      to_sql
    from("(#{sql}) AS #{table_name}").where("r=1")
  end
  scope :best_of, -> (discipline, gender) do
    sql = Score.discipline(discipline).gender(gender).
      select("#{table_name}.*, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY time ) AS r").
      to_sql
    from("(#{sql}) AS #{table_name}").where("r=1")
  end

  scope :yearly_best, -> (competitions) do
    times_subquery = Score
      .joins(:competition, :person)
      .select("
        #{Score.table_name}.discipline, 
        #{Person.table_name}.gender, 
        EXTRACT(YEAR FROM #{Competition.table_name}.date) AS year,
        MIN(#{Score.table_name}.time) AS time
      ")
      .german
      .where(competition_id: competitions)
      .group("
        #{Score.table_name}.discipline, 
        #{Person.table_name}.gender, 
        EXTRACT(YEAR FROM #{Competition.table_name}.date)
      ")
      .to_sql

    scores_subquery = Score
      .joins(:competition, :person)
      .joins("INNER JOIN times t ON t.discipline = #{Score.table_name}.discipline AND t.time = #{Score.table_name}.time AND t.year = EXTRACT(YEAR FROM #{Competition.table_name}.date) AND t.gender = #{Person.table_name}.gender")
      .select("
        #{Score.table_name}.id
      ")
      .german
      .where(competition_id: competitions)
      .to_sql

    includes(:person, competition: [:place, :event]).where("#{Score.table_name}.id IN (WITH times AS (#{times_subquery}) #{scores_subquery})").joins(:person, :competition)
    .order("
      #{Score.table_name}.discipline, 
      #{Person.table_name}.gender, 
      EXTRACT(YEAR FROM #{Competition.table_name}.date)
    ")
  end

  def uniq_team_id
    "#{competition_id}-#{team_id}-#{team_number}"
  end

  def <=>(other)
    time <=> other.time
  end

  def entity_id
    person_id
  end

  def entity
    person  
  end

  def similar_scores
    Score.where(competition_id: competition_id, person_id: person_id).order(:id)
  end
end