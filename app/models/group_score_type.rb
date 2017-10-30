class GroupScoreType < ActiveRecord::Base
  has_many :group_score_categories, dependent: :restrict_with_exception

  scope :competition, ->(competition_id) { joins(:group_score_categories).where(group_score_categories: { competition_id: competition_id }) }
  scope :filter_collection, -> { order(:discipline, :name) }

  validates :discipline, :name, presence: true
end
