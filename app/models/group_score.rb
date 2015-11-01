class GroupScore < ActiveRecord::Base
  belongs_to :team
  belongs_to :group_score_category
  has_many :person_participations
  has_many :persons, through: :person_participations

  enum gender: { female: 0, male: 1 }

  scope :valid, -> { where.not(time: Score::INVALID) }
  scope :gender, -> (gender) { where(gender: GroupScore.genders[gender]) }
  scope :discipline, -> (discipline) do 
    joins(group_score_category: :group_score_type).
    where(group_score_types: { discipline: discipline })
  end
  scope :year, -> (year) { joins(group_score_category: :competition).merge(Competition.year(year)) }

  validates :team, :group_score_category, :team_number, :gender, :time, presence: true
  
  delegate :competition, to: :group_score_category
end
