# frozen_string_literal: true

class Ui::TableOfContents
  include ActionView::Helpers::TagHelper
  include Ui::UniqIdFinder
  attr_reader :ankers
  alias elements ankers

  Anker = Struct.new(:name, :id)

  def index
    '|||TOC_PLACEHOLDER_TOC|||'
  end

  def anker(name, element = nil, options = {})
    @ankers ||= []
    tag_value = options[:tag_value] || name
    label_value = options[:label_value] || name
    id = available_id(name)
    @ankers.push(Anker.new(label_value, id))
    element_tag = element.present? ? content_tag(element, tag_value) : ''
    content_tag(:a, '', id: "toc-#{id}") + element_tag
  end

  def handle(content)
    content.gsub(index, generated_index)
  end

  def generated_index
    ac = ActionController::Base.new
    ac.render_to_string(partial: 'ui/table_of_contents', locals: { ankers: })
  end
end
