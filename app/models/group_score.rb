# frozen_string_literal: true

class GroupScore < ApplicationRecord
  include Firesport::TimeInvalid

  belongs_to :team
  belongs_to :group_score_category
  has_many :person_participations, dependent: :restrict_with_exception
  has_many :persons, through: :person_participations
  delegate :discipline, to: :group_score_category

  enum :gender, { female: 0, male: 1 }

  scope :gender, ->(gender) { where(gender: GroupScore.genders[gender]) }
  scope :discipline, ->(discipline) do
    joins(group_score_category: :group_score_type)
      .where(group_score_types: { discipline: })
  end
  scope :year, ->(year) { joins(group_score_category: :competition).merge(Competition.year(year)) }
  scope :best_of_competition, ->(single_run = false) do
    run = single_run ? '' : ", #{table_name}.run"
    distinct_column = "CONCAT(#{table_name}.group_score_category_id, '-', #{table_name}.team_id, '-', " \
                      "#{table_name}.team_number, #{table_name}.gender#{run})"
    select("DISTINCT ON (#{distinct_column}) #{table_name}.*").order(Arel.sql("#{distinct_column}, #{table_name}.time"))
  end
  scope :regular, -> { joins(group_score_category: :group_score_type).where(group_score_types: { regular: true }) }
  scope :without_members, ->(d) do
    inner_sql = GroupScore
                .unscoped
                .select('COUNT(person_participations.id) AS members_count, group_scores.*')
                .discipline(d)
                .joins('LEFT JOIN person_participations ON person_participations.group_score_id = group_scores.id')
                .group(:id)
                .to_sql
    from("(#{inner_sql}) group_scores").where("members_count < #{Discipline.participation_count(d)}")
  end
  scope :group_score_type, ->(group_type) do
    joins(:group_score_category).where(group_score_categories: { group_score_type_id: group_type.id })
  end
  scope :best_of_year, ->(year, discipline, gender) do
    sql = GroupScore.unscoped.regular.year(year).discipline(discipline).gender(gender)
                    .select("#{table_name}.*, ROW_NUMBER() OVER (PARTITION BY team_id ORDER BY time ) AS r")
                    .to_sql
    from("(#{sql}) AS #{table_name}").where('r=1')
  end
  scope :best_of, ->(discipline, gender) do
    sql = GroupScore.unscoped.regular.discipline(discipline).gender(gender)
                    .select("#{table_name}.*, ROW_NUMBER() OVER (PARTITION BY team_id ORDER BY time ) AS r")
                    .to_sql
    from("(#{sql}) AS #{table_name}").where('r=1')
  end
  schema_validations

  def self.yearly_best_times_subquery(competitions)
    GroupScore
      .joins(group_score_category: :competition)
      .select("
        #{GroupScoreCategory.table_name}.group_score_type_id,
        #{GroupScore.table_name}.gender,
        EXTRACT(YEAR FROM #{Competition.table_name}.date) AS year,
        MIN(#{GroupScore.table_name}.time) AS time
      ")
      .where(group_score_categories: { competition_id: competitions })
      .group("
        #{GroupScoreCategory.table_name}.group_score_type_id,
        #{GroupScore.table_name}.gender,
        EXTRACT(YEAR FROM #{Competition.table_name}.date)
      ")
      .to_sql
  end

  def self.yearly_best_scores_subquery(competitions)
    GroupScore
      .joins(group_score_category: :competition)
      .joins("INNER JOIN times t
        ON t.group_score_type_id = #{GroupScoreCategory.table_name}.group_score_type_id
        AND t.time = #{GroupScore.table_name}.time
        AND t.year = EXTRACT(YEAR FROM #{Competition.table_name}.date)
        AND t.gender = #{GroupScore.table_name}.gender")
      .select("
        #{GroupScore.table_name}.id
      ")
      .where(group_score_categories: { competition_id: competitions })
      .to_sql
  end
  scope :yearly_best, ->(competitions) do
    includes(:team, group_score_category: [:group_score_type, { competition: %i[place event] }])
      .where("#{GroupScore.table_name}.id IN (WITH times AS (#{yearly_best_times_subquery(competitions)})  " \
             "#{yearly_best_scores_subquery(competitions)})")
      .joins(group_score_category: %i[competition group_score_type])
      .order(Arel.sql(<<~SQL.squish))
        #{GroupScoreType.table_name}.discipline,
        #{GroupScoreType.table_name}.regular DESC,
        #{GroupScoreType.table_name}.name,
        #{GroupScore.table_name}.gender,
        EXTRACT(YEAR FROM #{Competition.table_name}.date)
      SQL
  end
  scope :competition, ->(competition_id) do
    joins(:group_score_category).where(group_score_categories: { competition_id: })
  end
  scope :group_score_category, ->(group_score_category_id) { where(group_score_category_id:) }
  scope :person, ->(person_id) { joins(:person_participations).where(person_participations: { person_id: }) }
  scope :team, ->(team_id) { where(team_id:) }
  scope :where_time_like, ->(search_term) { where('time::TEXT ILIKE ?', "%#{search_term}%") }

  validates :team_number, :gender, :time, presence: true

  delegate :competition, to: :group_score_category

  def entity_id
    team_id
  end

  def entity
    team
  end

  def similar_scores
    GroupScore.where(team_id:, team_number:, group_score_category_id:)
              .gender(gender).order(:id)
  end

  def competition_scores_from_team
    @competition_scores_from_team ||= similar_scores.where(team_number:).sort_by(&:time)
  end

  def competition_scores_from_team_with_run
    @competition_scores_from_team_with_run ||= similar_scores.where(team_number:, run:).sort_by(&:time)
  end

  def <=>(other)
    sort_method(other)
  end

  def sort_method(other, method: :competition_scores_from_team)
    both = [send(method), other.send(method)].map(&:count)
    (0..(both.min - 1)).each do |i|
      compare = send(method)[i].time <=> other.send(method)[i].time
      next if compare == 0

      return compare
    end
    both.last <=> both.first
  end
end
