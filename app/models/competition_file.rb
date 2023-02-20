# frozen_string_literal: true

class CompetitionFile < ApplicationRecord
  POSSIBLE_KEYS = %i[
    zk_female hb_female hl_female gs_female fs_female la_female
    zk_male hb_male hl_male fs_male la_male
  ].freeze

  belongs_to :competition
  mount_uploader :file, ResultUploader
  scope :competition, ->(competition_id) { where(competition_id: competition_id) }

  validates :file, presence: true

  def keys
    keys_string.split(',')
  end

  def self.possible_keys
    POSSIBLE_KEYS.map { |key| key.to_s.split('_').push(key) }
  end

  def keys_params=(params)
    keys = []
    POSSIBLE_KEYS.each do |possible_key|
      keys.push(possible_key) if params[possible_key].present?
    end
    self.keys_string = keys.uniq.join(',')
  end
end
