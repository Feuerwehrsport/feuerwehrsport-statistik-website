module UI
  class TableOfContents
    include ActionView::Helpers::TagHelper
    include UniqIDFinder
    attr_reader :ankers
    alias_method :elements, :ankers

    def index
      "|||TOC_PLACEHOLDER_TOC|||"
    end

    def anker(name, element=nil)
      @ankers ||= []
      id = available_id(name)
      @ankers.push(OpenStruct.new(name: name, id: id))
      element_tag = element.present? ? content_tag(element, name) : ""
      content_tag(:a, "", id: "toc-#{id}") + element_tag
    end

    def handle(content)
      content.gsub(index, generated_index)
    end

    def generated_index
      ac = ActionController::Base.new
      ac.render_to_string(partial: 'ui/table_of_contents', locals: { ankers: ankers })
    end
  end
end
