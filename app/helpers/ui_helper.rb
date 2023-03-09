# frozen_string_literal: true

module UiHelper
  def count_table(rows, options = {}, &block)
    table_class = options.delete(:table_class) || Ui::CountTable
    ct = table_class.new(self, rows, options, &block)
    render 'ui/count_table', ct: ct
  end

  def table_of_contents(&block)
    toc = Ui::TableOfContents.new
    toc.handle(capture_haml(toc, &block)).html_safe # rubocop:disable Rails/OutputSafety
  end

  def nav_tab(&block)
    nt = Ui::NavTab.new(&block)
    render 'ui/nav_tab', nt: nt
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
