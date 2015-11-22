class ResourceController < CacheController
  include ResourceAccess

  protected
  
  def page_title_default(default=nil)
    super(resource_class.model_name.human(count: 0))
  end
end