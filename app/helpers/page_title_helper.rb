# frozen_string_literal: true

module PageTitleHelper
  def page_title
    @page_title ||= t3('page_title', default: '').presence
    if @page_title.present?
      @page_title
    elsif resource.present?
      begin
        resource.try(:decorate).try(:page_title).presence || resource_class.model_name.human
      rescue Draper::UninferrableDecoratorError
        resource_class.model_name.human
      end
    elsif collection.present?
      resource_class.model_name.human(count: :many)
    end
  end
end
