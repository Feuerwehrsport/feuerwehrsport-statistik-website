# frozen_string_literal: true

class PlaceDecorator < AppDecorator
  decorates_association :competitions

  delegate :to_s, to: :name

  def page_title
    "#{name} - Wettkampfort"
  end
end
