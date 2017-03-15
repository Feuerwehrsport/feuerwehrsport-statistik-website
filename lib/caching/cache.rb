require 'fileutils'
require 'singleton'

class Caching::Cache < ActiveSupport::Cache::FileStore
  include Singleton
  class_attribute :caching
  self.caching = true

  def initialize
    FileUtils.mkdir_p(cache_path)
    super(cache_path)
  end

  def fetch(*args, &block)
    if Rails.configuration.caching && self.caching
      super(*args, &block)
    else
      yield
    end
  end

  def cache_path
    File.join(Rails.root, 'tmp', 'file-cache')
  end

  def self.method_missing(m, *args, &block)
    instance.send(m, *args, &block)
  end

  def self.disable
    caching_before = self.caching
    self.caching = false
    begin
      yield
    rescue Exception => e
      self.caching = caching_before
      raise e
    end
    self.caching = caching_before
  end
end