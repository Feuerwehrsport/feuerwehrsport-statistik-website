module Caching
  class Cleaner
    def initialize
      path = File.join(Rails.root, "public", "cache")
      `rm -rf "#{path}"`

      Rails.cache.clear
      Cache.clear

      Builder.enqueue
    end
  end
end