class ResourceController < ApplicationController
  def self.resource_actions(*action_names)
    options   = action_names.extract_options!
    cache     = options.delete(:cache) || []
    default_actions(*action_names, options)
    cache = [cache] unless cache.is_a?(Array)
    cache_actions(*cache)

    define_method(:paginate?) { false }
  end
end
