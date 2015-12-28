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

  validates :team, :group_score_category, :team_number, :gender, :time, presence: true

  delegate :competition, to: :group_score_category

  def entity_id
    team_id
  end

  def entity
    team
  end

  def similar_scores
    GroupScore.where(team_id: team_id, group_score_category_id: group_score_category_id).gender(gender).order(:id)
  end
end
