class Competition < ActiveRecord::Base
  belongs_to :place
  belongs_to :event
  belongs_to :score_type
  has_many :group_score_categories
  has_many :scores

  validates :place, :event, :date, presence: true
end
