# frozen_string_literal: true

class YearDecorator < AppDecorator
  def to_s
    object.year.to_i.to_s
  end

  def page_title
    "Jahr #{@year}"
  end

  def to_i
    object.year.to_i
  end
end
