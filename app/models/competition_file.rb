class CompetitionFile < ActiveRecord::Base
  POSSIBLE_KEYS = [
    :zk_female, :hb_female, :hl_female, :gs_female, :fs_female, :la_female,
    :zk_male, :hb_male, :hl_male, :fs_male, :la_male,
  ]

  belongs_to :competition
  mount_uploader :file, ResultUploader

  validates :file, :competition, presence: true

  def keys
    keys_string.split(",")
  end
end
