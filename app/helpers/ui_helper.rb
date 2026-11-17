# frozen_string_literal: true

module UiHelper
  def count_table(rows, options = {}, &)
    table_class = options.delete(:table_class) || Ui::CountTable
    ct = table_class.new(self, rows, options, &)
    render 'ui/count_table', ct:
  end

  def table_of_contents(&)
    toc = Ui::TableOfContents.new
    toc.handle(capture_haml(toc, &)).html_safe
  end

  # white head band of a page: breadcrumb, title, chips, key figures and section navigation
  def page_head(title, kicker: nil, breadcrumb: nil, chips: nil, tiles: nil, image: nil, toc: nil, &block)
    render 'ui/page_head', title:, kicker:, breadcrumb: Array(breadcrumb), chips: Array(chips).compact_blank,
                           tiles: Array(tiles), image:, toc:, extra: block ? capture(&block) : nil
  end

  # white card for one section; with toc the heading becomes an entry of the section navigation
  def content_card(title = nil, toc: nil, heading: :h2, label: nil, action: nil, **options, &)
    head = if title.nil?
             ''.html_safe
           elsif toc
             toc.anker(title, heading, label_value: label || title)
           else
             content_tag(heading, title)
           end
    head = content_tag(:div, head + action, class: 'content-card-head') if action
    content_tag(:section, head + capture(&), **options, class: ['content-card', options[:class]])
  end

  def nav_tab(&)
    nt = Ui::NavTab.new(&)
    render 'ui/nav_tab', nt:
  end

  def youtube_video(id, options = {})
    options = { width: 400, height: 225, frameborder: 0, allowfullscreen: true }.merge(options)
    options[:src] = "https://www.youtube-nocookie.com/embed/#{id}"
    content_tag(:iframe, '', options)
  end

  def badge_count(scope)
    content_tag(:span, scope.count, class: 'badge') if scope.all.present?
  end
end
