require 'fileutils'
require 'singleton'

module Caching
  class Cache < ActiveSupport::Cache::FileStore
    include Singleton

    def initialize
      FileUtils.mkdir_p(cache_path)
      super(cache_path)
    end

    def cache_path
      File.join(Rails.root, 'tmp', 'file-cache')
    end

    def self.method_missing(m, *args, &block)
      instance.send(m, *args, &block)
    end
  end
end