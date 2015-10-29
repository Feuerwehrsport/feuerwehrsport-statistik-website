class GroupScoreCategory < ActiveRecord::Base
  belongs_to :group_score_type
  belongs_to :competition
  has_many :group_scores

  validates :group_score_type, :competition, :name, presence: true
end
