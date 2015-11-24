class GroupScoreTypeDecorator < ApplicationDecorator
  include Indexable
  index_columns :id, :name, :discipline, :regular

  delegate :to_s, to: :name
end
