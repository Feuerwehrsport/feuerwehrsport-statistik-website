class GroupScoreCategory < ActiveRecord::Base
  belongs_to :group_score_type
  belongs_to :competition
  has_many :group_scores, dependent: :restrict_with_exception

  scope :discipline, -> (discipline) do 
    joins(:group_score_type).
    where(group_score_types: { discipline: discipline })
  end

  validates :group_score_type, :competition, :name, presence: true
end
