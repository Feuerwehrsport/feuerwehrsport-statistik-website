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

    Caching::Builder.enqueue_with_options(run_at: 5.minutes.from_now) if Rails.configuration.caching
    Caching::HeavyBuilder.enqueue_with_options(run_at: Date.current.end_of_day) if Rails.configuration.caching
    true
  end
end
