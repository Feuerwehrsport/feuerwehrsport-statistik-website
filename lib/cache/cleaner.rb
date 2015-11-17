module Cache
  class Cleaner
    def initialize
      path = File.join(Rails.root, "public", "cache")
      `rm -rf "#{path}"`
    end
  end
end