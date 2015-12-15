class CompetitionFile < ActiveRecord::Base
  POSSIBLE_KEYS = [
    :zk_female, :hb_female, :hl_female, :gs_female, :fs_female, :la_female,
    :zk_male, :hb_male, :hl_male, :fs_male, :la_male,
  ]

  belongs_to :competition
  mount_uploader :file, ResultUploader

  validates :file, :competition, presence: true
  validates :file, file_mime_type: { content_type: /pdf/ }

  def keys
    keys_string.split(",")
  end

  def self.possible_keys
    POSSIBLE_KEYS.map { |key| key.to_s.split('_').push(key) }
  end

  def keys_params=(params)
    keys = []
    POSSIBLE_KEYS.each do |possible_key|
      keys.push(possible_key) if params[possible_key].present?
    end
    self.keys_string = keys.join(",")
  end
end
