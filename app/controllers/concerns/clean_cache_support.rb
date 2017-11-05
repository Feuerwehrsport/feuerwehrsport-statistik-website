module CleanCacheSupport
  extend ActiveSupport::Concern

  def after_create
    clean_cache_and_build_new
    super
  end

  def after_update
    clean_cache_and_build_new
    super
  end

  def after_destroy
    clean_cache_and_build_new
    super
  end
end
