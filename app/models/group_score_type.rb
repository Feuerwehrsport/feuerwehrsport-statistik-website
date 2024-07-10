# frozen_string_literal: true

class GroupScoreType < ApplicationRecord
  has_many :group_score_categories, dependent: :restrict_with_exception

  scope :competition, ->(competition_id) do
    joins(:group_score_categories).where(group_score_categories: { competition_id: })
  end
  scope :filter_collection, -> { order(:discipline, :name) }

  validates :discipline, :name, presence: true

  def self.din_wko
    @din_wko ||= GroupScoreType.find_by!(name: 'WKO DIN-Pumpe')
  end

  def self.tgl_wko
    @tgl_wko ||= GroupScoreType.find_by!(name: 'WKO TGL-Pumpe')
  end
end
