# frozen_string_literal: true

class GroupScoreType < ApplicationRecord
  has_many :group_score_categories, dependent: :restrict_with_exception

  scope :competition, ->(competition_id) do
    joins(:group_score_categories).where(group_score_categories: { competition_id: })
  end
  scope :filter_collection, -> { order(:discipline, :name) }

  validates :discipline, :name, :key, presence: true
  validates :key, format: { with: /\A[a-z0-9_]+\z/ }
  schema_validations

  # found by the fixed key, the names can be changed
  def self.din_wko
    @din_wko ||= GroupScoreType.find_by!(key: 'din_zielgeraete')
  end

  def self.tgl_wko
    @tgl_wko ||= GroupScoreType.find_by!(key: 'tgl_zielgeraete')
  end
end
