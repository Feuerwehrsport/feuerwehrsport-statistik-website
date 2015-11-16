class Person < ActiveRecord::Base
  include Genderable

  belongs_to :nation
  has_many :person_participations
  has_many :group_scores, through: :person_participations
  has_many :scores
  has_many :score_double_events
  has_many :group_score_participations
  has_many :team_members
  has_many :teams, through: :team_members

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

  validates :last_name, :gender, :nation, presence: true
end
