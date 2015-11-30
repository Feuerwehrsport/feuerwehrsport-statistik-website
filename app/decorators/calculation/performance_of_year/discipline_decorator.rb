module Calculation
  module PerformanceOfYear
    class DisciplineDecorator < ApplicationDecorator
      decorates_association :entries
    end
  end
end
