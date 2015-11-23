module UIHelper
  def crud_table(rows, options={}, &block)
    count_table(rows, options.merge(table_class: UI::CRUDTable), &block)
  end

  def count_table rows, options={}, &block
    table_class = options.delete(:table_class) || UI::CountTable
    ct = table_class.new(self, rows, options, &block)
    render 'ui/count_table', ct: ct
  end

  def table_of_contents &block
    toc = UI::TableOfContents.new
    toc.handle(capture_haml toc, &block).html_safe
  end

  def nav_tab &block
    nt = UI::NavTab.new &block
    render 'ui/nav_tab', nt: nt
  end

  def button_dropdown(resource, options={})
    UI::ButtonDropdown.new(self, resource, options)
  end
end