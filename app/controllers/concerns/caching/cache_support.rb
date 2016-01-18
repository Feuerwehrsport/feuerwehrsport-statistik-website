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

    protected

    def save_html_cache
      if self.class.cache_action?(action_name) && request.format.to_sym == :html && Rails.configuration.caching
        uri = URI.parse(request.url).path
        path = File.join(Rails.root, "public", "cache", File.dirname(uri))
        FileUtils.mkdir_p(path)
        basename = File.basename(uri)
        basename += "_index" if basename.ends_with?("/")
        file_path = File.join(path, "#{basename}.html")
        logger.debug("CACHING: #{file_path}")
        File.open(file_path, "w+") do |f|
          f.write(response.body)
        end
      end
    end

    def clean_cache_and_build_new
      Caching::Cleaner.new.perform
      Caching::Builder.enqueue_with_options(run_at: Time.now + 5.minutes)
    end
  end
end
