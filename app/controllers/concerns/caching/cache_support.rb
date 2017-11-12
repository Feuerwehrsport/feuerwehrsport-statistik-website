module Caching::CacheSupport
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
    after_action :save_html_cache
    helper_method :save_html_cache?
  end

  protected

  def save_html_cache?(content_type: 'text/html')
    self.class.cache_action?(action_name) && cache_format?(content_type) && Rails.configuration.caching
  end

  def cache_format?(_cont)
    request.format.to_sym == :html || content_type == 'text/html'
  end

  def save_html_cache
    return unless save_html_cache?(content_type: response.content_type)
    uri = URI.parse(request.url).path
    path = Rails.root.join('public', 'cache', File.dirname(uri).gsub(%r{^/}, ''))
    FileUtils.mkdir_p(path)
    basename = File.basename(uri)
    basename += '_index' if basename.ends_with?('/')
    file_path = File.join(path, "#{basename}.html")
    logger.debug("CACHING: #{file_path}")
    File.write(file_path, response.body)
  end

  def clean_cache_and_build_new
    Caching::Cleaner.new.save
  end
end
