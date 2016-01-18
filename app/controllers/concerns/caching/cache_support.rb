module Caching
  module CacheSupport
    extend ActiveSupport::Concern
    class_methods do
      def cache_actions(*actions)
        @cache_actions = actions
      end

      def cache_action?(action_name)
        action_name.to_sym.in?(@cache_actions || [])
      end
    end

    included do
      after_filter :save_html_cache
    end

    def save_html_cache
      if self.class.cache_action?(action_name) && request.format.to_sym == :html && Rails.configuration.caching
        uri = URI.parse(request.url).path
        path = File.join(Rails.root, "public", "cache", File.dirname(uri))
        FileUtils.mkdir_p(path)
        File.open(File.join(path, "#{File.basename(uri)}.html"), "w+") do |f|
          f.write(response.body)
        end
      end
    end
  end
end
