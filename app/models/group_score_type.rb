class GroupScoreType < ActiveRecord::Base
  has_many :group_score_categories, dependent: :restrict_with_exception

  validates :discipline, :name, presence: true
end
