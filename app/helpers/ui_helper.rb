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
  def page_head(title, kicker: nil, breadcrumb: nil, chips: nil, tiles: nil, image: nil, toc: nil, actions: nil,
                &block)
    render 'ui/page_head', title:, kicker:, breadcrumb: Array(breadcrumb).compact_blank,
                           chips: Array(chips).compact_blank, tiles: Array(tiles), image:, toc:, actions:,
                           extra: block ? capture(&block) : nil
  end

  def breadcrumb_join(items)
    safe_join(items.compact_blank, content_tag(:span, '›', class: 'sep', 'aria-hidden': 'true'))
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

  # two-click solution: nothing is loaded from YouTube until the video is started (stimulus video-consent)
  def youtube_video(id, title:)
    render 'ui/youtube_video', id:, title:
  end

  # logo of the site (same drawing as public/favicon.svg): three rising bars on a dark rounded square
  LOGO_BARS = [[4, 16, 11, '#FFFFFF'], [13, 11, 16, '#E02424'], [22, 7, 20, '#FFFFFF']].freeze

  def logo_mark(size)
    bars = LOGO_BARS.map { |x, y, height, fill| tag.rect(x:, y:, width: 6, height:, rx: 1.5, fill:) }
    tag.svg(width: size, height: size, viewBox: '0 0 32 32', class: 'logo-mark', 'aria-hidden': 'true') do
      safe_join([tag.rect(width: 32, height: 32, rx: 7, fill: '#14202B'), *bars])
    end
  end

  # link of a .nav-list, optionally with a counter of open tasks
  def nav_list_link(label, path, count = nil)
    link_to(path) do
      content_tag(:span, label) +
        (count.to_i.positive? ? content_tag(:span, count, class: 'badge rounded-pill text-bg-danger') : ''.html_safe)
    end
  end
end
