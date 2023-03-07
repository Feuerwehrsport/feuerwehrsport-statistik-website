# frozen_string_literal: true

module M3Rspec
  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
    end

    def seed(&block)
      Seed.block = block
    end
  end

  class Configuration
    attr_accessor :screenshot_sleep, :open_screenshots, :screenshots_disabled

    def initialize
      @screenshot_sleep = (ENV['SCREENSHOT_SLEEP'].presence || '0.6').to_f
      @open_screenshots = ENV['DISABLE_SCREENSHOT_OPEN'].blank?
      @screenshots_disabled = ENV['SCREENSHOTS_DISABLED'].present?
    end

    def open_screenshots?
      @open_screenshots
    end

    def screenshot_sleep?
      @screenshot_sleep > 0.0
    end
  end
end

M3Rspec.configure
