class Caching::Cleaner
  def perform
    if Rails.configuration.caching
      clean_nginx_cache
      clean_rails_cache
      clean_statistik_cache
    end
  end

  def clean_nginx_cache
    path = File.join(Rails.root, 'public', 'cache')
    Rails.logger.debug("CACHING_CLEAN: #{`find #{path}`}")
    `rm -rf "#{path}"`
  end

  def clean_rails_cache
    Rails.cache.clear
  end

  def clean_statistik_cache
    Caching::Cache.clear
  end
end
