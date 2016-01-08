class Person < ActiveRecord::Base
  include Genderable

  belongs_to :nation
  has_many :person_participations, dependent: :restrict_with_exception
  has_many :group_scores, through: :person_participations
  has_many :scores, dependent: :restrict_with_exception
  has_many :score_double_events
  has_many :group_score_participations
  has_many :team_members
  has_many :teams, through: :team_members
  has_many :person_spellings, dependent: :restrict_with_exception
  has_many :series_participations, dependent: :restrict_with_exception, class_name: 'Series::PersonParticipation'

  scope :with_score_count, -> do
    select("
      people.*,
      (#{Score.select("COUNT(*)").hb.where("person_id = people.id").to_sql}) AS hb_count,
      (#{Score.select("COUNT(*)").hl.where("person_id = people.id").to_sql}) AS hl_count,
      (#{GroupScoreParticipation.la.select("COUNT(*)").where("person_id = people.id").to_sql}) AS la_count,
      (#{GroupScoreParticipation.fs.select("COUNT(*)").where("person_id = people.id").to_sql}) AS fs_count,
      (#{GroupScoreParticipation.gs.select("COUNT(*)").where("person_id = people.id").to_sql}) AS gs_count
    ")
  end
  scope :german, -> { where(nation_id: 1) }
  scope :search, -> (value) do
    search_value = "%#{value}%"
    where("first_name ILIKE ? OR last_name ILIKE ?", search_value, search_value)
  end
  scope :index_order, -> { order(:last_name, :first_name) }

  validates :last_name, :gender, :nation, presence: true

  def merge_to(correct_person)
    raise ActiveRecord::ActiveRecordError.new("same id") if id == correct_person.id

    scores.update_all(person_id: correct_person.id)
    person_participations.update_all(person_id: correct_person.id)
    person_spellings.update_all(person_id: correct_person.id)
    series_participations.update_all(person_id: correct_person.id)
  end
end
