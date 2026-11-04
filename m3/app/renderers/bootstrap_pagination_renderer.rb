# frozen_string_literal: true

require 'will_paginate/view_helpers/action_view'

# rubocop:disable Rails/ContentTag -- tag is WillPaginate::ViewHelpers::LinkRenderer#tag

# will_paginate renderer for bootstrap 3 markup (replacement for the will_paginate-bootstrap gem)
class BootstrapPaginationRenderer < WillPaginate::ActionView::LinkRenderer
  def to_html
    list_items = pagination.map do |item|
      item.is_a?(Integer) ? page_number(item) : send(item)
    end.join(@options[:link_separator])

    tag(:ul, list_items, class: ['pagination', @options[:class]].compact.join(' '))
  end

  protected

  def page_number(page)
    if page == current_page
      tag(:li, tag(:span, page), class: 'active')
    else
      tag(:li, link(page, page, rel: rel_value(page)))
    end
  end

  def gap
    tag(:li, tag(:span, '&hellip;'), class: 'disabled')
  end

  def previous_page
    num = @collection.current_page > 1 && (@collection.current_page - 1)
    previous_or_next_page(num, @options[:previous_label], 'prev')
  end

  def next_page
    num = @collection.current_page < @collection.total_pages && (@collection.current_page + 1)
    previous_or_next_page(num, @options[:next_label], 'next')
  end

  def previous_or_next_page(page, text, classname)
    if page
      tag(:li, link(text, page), class: classname)
    else
      tag(:li, tag(:span, text), class: "#{classname} disabled")
    end
  end
end
# rubocop:enable Rails/ContentTag
