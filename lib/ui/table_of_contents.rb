module UI
  class TableOfContents
    include ActionView::Helpers::TagHelper
    attr_reader :ankers

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

    def available_id(name)
      regular = name.parameterize
      return regular if id_available?(regular)
      i = 1
      i += 1 while !id_available?("#{regular}-#{i}")
      "#{regular}-#{i}"
    end

    def id_available?(id)
      !ankers.any? { |a| a.id == id }
    end
  end
end
