class Team < ActiveRecord::Base
  include GeoPosition
  STATUS = { team: 0, fire_station: 1 }
  enum status: STATUS
  
  has_many :group_scores, dependent: :restrict_with_exception
  has_many :scores, dependent: :restrict_with_exception
  has_many :person_participations, through: :group_scores
  has_many :group_people, through: :person_participations, class_name: 'Person', 
    foreign_key: 'person_id', source: :person
  has_many :people, through: :scores
  has_many :team_members
  has_many :members, through: :team_members, class_name: 'Person', 
    foreign_key: 'person_id', source: :person
  has_many :team_competitions
  has_many :competitions, through: :team_competitions
  has_many :group_score_participations
  has_many :links, as: :linkable, dependent: :restrict_with_exception

  mount_uploader :image, TeamLogoUploader

  validates :name, :shortcut, presence: true

  scope :with_members_and_competitions_count, -> do
    select("
      teams.*,
      (#{TeamMember.select("COUNT(*)").where("team_id = teams.id").to_sql}) AS members_count,
      (#{TeamCompetition.select("COUNT(*)").where("team_id = teams.id").to_sql}) AS competitions_count
    ")
  end
  scope :status, -> (status) { where(status: STATUS[status.to_sym]) }

  def person_scores_count(person)
    scores.where(person: person).count + person_participations.where(person: person).count
  end
end
