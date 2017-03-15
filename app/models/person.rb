class Person < ActiveRecord::Base
  include Genderable

  belongs_to :nation
  has_many :person_participations, dependent: :restrict_with_exception
  has_many :group_scores, through: :person_participations
  has_many :scores, dependent: :restrict_with_exception
  has_many :score_double_events
  has_many :score_low_double_events
  has_many :group_score_participations
  has_many :team_members
  has_many :teams, through: :team_members
  has_many :person_spellings, dependent: :restrict_with_exception
  has_many :series_participations, dependent: :restrict_with_exception, class_name: 'Series::PersonParticipation'
  has_many :entity_merges, as: :target

  scope :german, -> { where(nation_id: 1) }
  scope :search, -> (value) do
    search_value = "%#{value}%"
    where("first_name ILIKE ? OR last_name ILIKE ?", search_value, search_value)
  end
  scope :search_exactly, -> (last_name, first_name) do
    where("last_name ILIKE ? AND first_name ILIKE ?", last_name, first_name)
  end
  scope :index_order, -> { order(:last_name, :first_name) }
  scope :where_name_like, -> (name) do
    query = "%#{name.split("").join("%")}%"
    spelling_query = PersonSpelling.where("(first_name || ' ' || last_name) ILIKE ?", query).select(:person_id)
    where("(first_name || ' ' || last_name) ILIKE ? OR id IN (#{spelling_query.to_sql})", query)
  end
  scope :order_by_teams, -> (other_teams) do
    sql = other_teams.joins(:team_members).where(team_members: { person_id: arel_table[:id] }).select("1").to_sql
    order("EXISTS(#{sql}) DESC")
  end

  validates :last_name, :gender, :nation, presence: true

  def self.update_score_count
    update_all("hb_count = (#{Score.select("COUNT(*)").low_and_high_hb.where("person_id = people.id").to_sql})")
    update_all("hl_count = (#{Score.select("COUNT(*)").hl.where("person_id = people.id").to_sql})")
    update_all("la_count = (#{GroupScoreParticipation.la.select("COUNT(*)").where("person_id = people.id").to_sql})")
    update_all("fs_count = (#{GroupScoreParticipation.fs.select("COUNT(*)").where("person_id = people.id").to_sql})")
    update_all("gs_count = (#{GroupScoreParticipation.gs.select("COUNT(*)").where("person_id = people.id").to_sql})")
  end

  def merge_to(correct_person)
    raise ActiveRecord::ActiveRecordError.new("same id") if id == correct_person.id

    scores.update_all(person_id: correct_person.id)
    person_participations.update_all(person_id: correct_person.id)
    person_spellings.update_all(person_id: correct_person.id)
    series_participations.update_all(person_id: correct_person.id)
    entity_merges.update_all(target_id: correct_person.id)
  end
end
