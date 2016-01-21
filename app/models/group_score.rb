class GroupScore < ActiveRecord::Base
  include TimeInvalid

  belongs_to :team
  belongs_to :group_score_category
  has_many :person_participations, dependent: :restrict_with_exception
  has_many :persons, through: :person_participations

  enum gender: { female: 0, male: 1 }

  scope :gender, -> (gender) { where(gender: GroupScore.genders[gender]) }
  scope :discipline, -> (discipline) do 
    joins(group_score_category: :group_score_type).
    where(group_score_types: { discipline: discipline })
  end
  scope :year, -> (year) { joins(group_score_category: :competition).merge(Competition.year(year)) }
  scope :best_of_competition, -> (single_run=false) do
    run = single_run ? '' : ", #{table_name}.run"
    distinct_column = "CONCAT(#{table_name}.group_score_category_id, '-', #{table_name}.team_id, '-', #{table_name}.team_number, #{table_name}.gender#{run})"
    select("DISTINCT ON (#{distinct_column}) #{table_name}.*").order("#{distinct_column}, #{table_name}.time")
  end
  scope :regular, -> { joins(group_score_category: :group_score_type).where(group_score_types: { regular: true }) }
  scope :without_members, -> (d) do
    inner_sql = GroupScore.
      select("COUNT(person_participations.id) AS members_count, group_scores.*").
      discipline(d).
      joins("LEFT JOIN person_participations ON person_participations.group_score_id = group_scores.id").
      group(:id).
      to_sql
    from("(#{inner_sql}) group_scores").where("members_count < #{Discipline.participation_count(d)}")
  end
  scope :group_score_type, -> (group_type) do
    joins(:group_score_category).where(group_score_categories: { group_score_type_id: group_type.id })
  end
  scope :best_of_year, -> (year, discipline, gender) do
    sql = GroupScore.year(year).discipline(discipline).gender(gender).
      select("#{table_name}.*, ROW_NUMBER() OVER (PARTITION BY team_id ORDER BY time ) AS r").
      to_sql
    from("(#{sql}) AS #{table_name}").where("r=1")
  end
  scope :best_of, -> (discipline, gender) do
    sql = GroupScore.discipline(discipline).gender(gender).
      select("#{table_name}.*, ROW_NUMBER() OVER (PARTITION BY team_id ORDER BY time ) AS r").
      to_sql
    from("(#{sql}) AS #{table_name}").where("r=1")
  end
  scope :yearly_best, -> (competitions) do
    times_subquery = GroupScore
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

    scores_subquery = GroupScore
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

    includes(:team, group_score_category: [:group_score_type, competition: [:place, :event]])
      .where("#{GroupScore.table_name}.id IN (WITH times AS (#{times_subquery}) #{scores_subquery})").joins(group_score_category: [:competition, :group_score_type])
      .order("
        #{GroupScoreType.table_name}.discipline,
        #{GroupScoreType.table_name}.regular DESC,
        #{GroupScoreType.table_name}.name,
        #{GroupScore.table_name}.gender, 
        EXTRACT(YEAR FROM #{Competition.table_name}.date)
      ")
  end

  validates :team, :group_score_category, :team_number, :gender, :time, presence: true

  delegate :competition, to: :group_score_category

  def entity_id
    team_id
  end

  def entity
    team
  end

  def similar_scores
    GroupScore.where(team_id: team_id, team_number: team_number, group_score_category_id: group_score_category_id).gender(gender).order(:id)
  end

  def competition_scores_from_team
    @competition_scores_from_team ||= similar_scores.where(team_number: team_number).sort_by(&:time)
  end

  def <=>(other)
    both = [competition_scores_from_team, other.competition_scores_from_team].map(&:count)
    (0..(both.min - 1)).each do |i|
      compare = competition_scores_from_team[i].time <=> other.competition_scores_from_team[i].time
      next if compare == 0
      return compare
    end
    both.last <=> both.first
  end
end
