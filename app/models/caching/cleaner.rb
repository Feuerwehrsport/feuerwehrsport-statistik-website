# frozen_string_literal: true

class Caching::Cleaner
  include M3::FormObject

  def save
    Rails.logger.debug('CACHING: CLEAN')
    FileUtils.rm_r(Rails.public_path.join('cache'), force: true)
    begin
      Caching::Cache.clear
    rescue Errno::ENOENT => e
      Rails.logger.debug(e.message)
    end

    Caching::Builder.set(wait: 5.minutes).perform_later if Rails.configuration.caching
    Caching::HeavyBuilder.set(wait: 10.minutes).perform_later if Rails.configuration.caching
    true
  end
end
