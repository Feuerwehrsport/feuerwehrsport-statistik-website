class Caching::Cleaner
  include M3::FormObject

  def save
    Rails.logger.debug('CACHING: CLEAN')
    FileUtils.rm_r(Rails.root.join('public', 'cache'), force: true)
    begin
      Caching::Cache.clear
    rescue Errno::ENOENT
    end

    Caching::Builder.enqueue_with_options(run_at: Time.current + 5.minutes) if Rails.configuration.caching
    true
  end
end
