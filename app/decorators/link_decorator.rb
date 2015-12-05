class LinkDecorator < ApplicationDecorator
  include Indexable
  index_columns :id, :label, :linkable

  decorates_association :linkable

  def to_s
    object.label
  end
end
