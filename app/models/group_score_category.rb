# frozen_string_literal: true

class GroupScoreCategory < ApplicationRecord
  belongs_to :group_score_type
  belongs_to :competition
  has_many :group_scores, dependent: :restrict_with_exception
  delegate :discipline, to: :group_score_type

  scope :discipline, ->(discipline) do
    joins(:group_score_type)
      .where(group_score_types: { discipline: discipline })
  end
  scope :competition, ->(competition_id) { where(competition_id: competition_id) }
  scope :group_score_type, ->(group_score_type_id) { where(group_score_type_id: group_score_type_id) }

  validates :name, presence: true
end
