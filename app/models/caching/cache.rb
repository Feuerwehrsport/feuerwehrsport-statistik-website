# frozen_string_literal: true

class Caching::Cache < ActiveSupport::Cache::FileStore
  include Singleton
  class_attribute :caching
  self.caching = true

  def self.fetch(...)
    instance.fetch(...)
  end

  def self.clear(...)
    instance.clear(...)
  end

  def initialize
    FileUtils.mkdir_p(cache_path)
    super(cache_path)
  end

  def fetch(*args, &)
    if Rails.configuration.caching && caching
      begin
        super(*args, &)
      rescue Errno::ENOENT
        yield
      end
    else
      yield
    end
  end

  def cache_path
    Rails.root.join('tmp/file-cache')
  end

  def self.disable
    caching_before = caching
    self.caching = false
    begin
      yield
    rescue StandardError => e
      self.caching = caching_before
      raise e
    end
    self.caching = caching_before
  end
end
