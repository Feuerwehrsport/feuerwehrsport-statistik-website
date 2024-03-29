# frozen_string_literal: true

class Score < ApplicationRecord
  include Firesport::TimeInvalid

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

  belongs_to :person
  belongs_to :competition
  belongs_to :team
  has_many :hl_bla_badges, foreign_key: :hl_score_id, class_name: 'Bla::Badge', dependent: :nullify,
                           inverse_of: :hl_score
  has_many :hb_bla_badges, foreign_key: :hl_score_id, class_name: 'Bla::Badge', dependent: :nullify,
                           inverse_of: :hb_score

  validates :discipline, :time, :team_number, presence: true

  scope :gender, ->(gender) { joins(:person).merge(Person.gender(gender)) }
  scope :discipline, ->(discipline) { where(discipline:) }
  scope :hl, -> { discipline(:hl) }
  scope :hb, -> { discipline(:hb) }
  scope :hw, -> { discipline(:hw) }
  scope :low_and_high_hb, -> { where(discipline: %i[hb hw]) }
  scope :no_finals, -> { where('team_number >= 0') }
  scope :out_of_competition, -> { where(team_number: -5) }
  scope :finals, ->(final_number) { where(team_number: final_number) }
  scope :with_team, -> { where.not(team_id: nil) }
  scope :best_of_competition, -> do
    distinct_column = "CONCAT(#{table_name}.competition_id, '-', #{table_name}.person_id, #{table_name}.discipline)"
    select("DISTINCT ON (#{distinct_column}) #{table_name}.*").order(Arel.sql("#{distinct_column}, #{table_name}.time"))
  end
  scope :german, -> { joins(:person).merge(Person.german) }
  scope :year, ->(year) { joins(:competition).merge(Competition.year(year)) }
  scope :best_of_year, ->(year, discipline, gender) do
    sql = Score.unscoped.joins(:person).merge(Person.german).year(year).discipline(discipline).gender(gender)
               .select("#{table_name}.*, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY time ) AS r")
               .to_sql
    from("(#{sql}) AS #{table_name}").where('r=1')
  end
  scope :best_of, ->(discipline, gender) do
    sql = Score.unscoped
               .joins(:person).merge(Person.german).discipline(discipline).gender(gender)
               .select("#{table_name}.*, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY time ) AS r")
               .to_sql
    from("(#{sql}) AS #{table_name}").where('r=1')
  end

  def self.yearly_best_times_subquery(competitions)
    Score
      .joins(:competition, :person)
      .select(<<~SQL.squish)
        #{Score.table_name}.discipline,
        #{Person.table_name}.gender,
        EXTRACT(YEAR FROM #{Competition.table_name}.date) AS year,
        MIN(#{Score.table_name}.time) AS time
      SQL
      .german
      .where(competition_id: competitions)
      .group(<<~SQL.squish)
        #{Score.table_name}.discipline,
        #{Person.table_name}.gender,
        EXTRACT(YEAR FROM #{Competition.table_name}.date)
      SQL
      .to_sql
  end

  def self.yearly_best_scores_subquery(competitions)
    Score
      .joins(:competition, :person)
      .joins(
        "INNER JOIN times t ON t.discipline = #{Score.table_name}.discipline AND " \
        "t.time = #{Score.table_name}.time AND " \
        "t.year = EXTRACT(YEAR FROM #{Competition.table_name}.date) AND " \
        "t.gender = #{Person.table_name}.gender",
      )
      .select("#{Score.table_name}.id")
      .german
      .where(competition_id: competitions)
      .to_sql
  end

  scope :yearly_best, ->(competitions) do
    includes(:person, competition: %i[place event])
      .where("#{Score.table_name}.id IN (WITH times AS (#{yearly_best_times_subquery(competitions)}) " \
             "#{yearly_best_scores_subquery(competitions)})")
      .joins(:person, :competition)
      .order(Arel.sql(<<~SQL.squish))
        #{Score.table_name}.discipline,
        #{Person.table_name}.gender,
        EXTRACT(YEAR FROM #{Competition.table_name}.date)
      SQL
  end
  scope :competition, ->(competition_id) { where(competition_id:) }
  scope :person, ->(person_id) { where(person_id:) }
  scope :team, ->(team_id) { where(team_id:) }
  scope :where_time_like, ->(search_term) { where('time::TEXT ILIKE ?', "%#{search_term}%") }

  def uniq_team_id
    "#{competition_id}-#{team_id}-#{team_number}"
  end

  def <=>(other)
    both = [similar_scores, other.similar_scores].map(&:count)
    (0..(both.min - 1)).each do |i|
      compare = similar_scores[i].time <=> other.similar_scores[i].time
      next if compare.zero?

      return compare
    end
    both.last <=> both.first
  end

  def entity_id
    person_id
  end

  def entity
    person
  end

  def similar_scores
    @similar_scores ||= Score.where(
      competition_id:,
      person_id:,
      discipline:,
      team_number:,
    ).order(:time, :id)
  end
end
