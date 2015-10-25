class PlaceDecorator < ApplicationDecorator
  decorates_association :competitions

  delegate :to_s, to: :name
end
