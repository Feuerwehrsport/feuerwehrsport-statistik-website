module TimeInvalid
  INVALID = 99_999_999
  extend ActiveSupport::Concern

  included do
    scope :valid, -> { where.not(time: INVALID) }
    scope :invalid, -> { where(time: INVALID) }
  end

  def time_invalid?
    time == INVALID
  end
end
