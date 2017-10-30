module PageTitleHelper
  def page_title
    @page_title ||= t3('page_title', default: '').presence
    if @page_title.present?
      @page_title
    elsif resource.present?
      resource.respond_to?(:page_title) ? resource.page_title : resource_class.model_name.human
    elsif collection.present?
      resource_class.model_name.human(count: :many)
    end
  end
end
