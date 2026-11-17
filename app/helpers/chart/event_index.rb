# frozen_string_literal: true

class Chart::EventIndex < Chart::Base
  attr_accessor :events

  def events_count
    sorted = events.sort_by(&:count).reverse
    bar_chart(labels: sorted.map(&:to_s), values: sorted.map(&:count), name: 'Wettkämpfe', horizontal: true,
              height: (sorted.size * 18) + 40)
  end
end
