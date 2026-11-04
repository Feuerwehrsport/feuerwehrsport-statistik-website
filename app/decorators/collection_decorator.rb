# frozen_string_literal: true

class CollectionDecorator < Draper::CollectionDecorator
  delegate :current_page, :per_page, :offset, :total_entries, :total_pages, :klass

  def order(*)
    object.order(*).decorate
  end
end
