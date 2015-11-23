class PlaceDecorator < ApplicationDecorator
  include Indexable
  decorates_association :competitions
  index_columns :id, :name

  delegate :to_s, to: :name
end
