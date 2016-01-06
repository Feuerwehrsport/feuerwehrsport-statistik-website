module Caching
  class Cleaner
    def perform
      clean_nginx_cache
      clean_rails_cache
      clean_statistik_cache
    end

    def clean_nginx_cache
      path = File.join(Rails.root, "public", "cache")
      `rm -rf "#{path}"`
    end

    def clean_rails_cache
      Rails.cache.clear
    end

    def clean_statistik_cache
      Cache.clear
    end
  end
end