# frozen_string_literal: true

class Chart::YearIndex < Chart::Base
  attr_accessor :years

  def competitions_count
    sorted = years.sort_by(&:to_s).reverse
    bar_chart(labels: sorted.map(&:to_s), values: sorted.map(&:count), name: 'Wettkämpfe', horizontal: true,
              height: (sorted.size * 18) + 40)
  end
end
