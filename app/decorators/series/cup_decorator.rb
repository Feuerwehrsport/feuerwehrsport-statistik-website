module Series
  class CupDecorator < ApplicationDecorator
    decorates_association :round
    decorates_association :competition
  end
end
