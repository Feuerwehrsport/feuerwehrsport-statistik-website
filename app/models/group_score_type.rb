class GroupScoreType < ActiveRecord::Base
  has_many :group_score_categories

  validates :discipline, :name, presence: true
end
