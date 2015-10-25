class GroupScoreCategory < ActiveRecord::Base
  belongs_to :group_score_type
  belongs_to :competition
  has_many :scores

  validates :group_score_type, :competition, :name, presence: true
end
