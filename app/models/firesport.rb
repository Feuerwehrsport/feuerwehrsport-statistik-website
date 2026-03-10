# frozen_string_literal: true

module Firesport
  INVALID_TIME = 99_999_999

  module TimeInvalid
    extend ActiveSupport::Concern

    included do
      scope :valid, -> { where.not(time: INVALID_TIME) }
      scope :invalid, -> { where(time: INVALID_TIME) }
    end

    def time_invalid?
      time >= INVALID_TIME
    end

    def time_valid?
      !time_invalid?
    end
  end

  class Time
    def self.second_time(time)
      return 'D' if (time.is_a?(Float) || time.is_a?(BigDecimal)) && time.nan?
      return 'D' if time.blank?
      return 'D' if time >= INVALID_TIME

      minus = time.to_i.negative? ? '-' : ''
      deci = time.to_i.abs % 100
      seconds = (time.to_i.abs - deci) / 100
      "#{minus}#{seconds},#{format('%<deci>02d', deci: deci)}"
    end
  end
end
