class LinkDecorator < ApplicationDecorator
  include Indexable
  index_columns :id, :label, :linkable

  decorates_association :linkable

  def label
    object.label
  end

  def to_s
    object.label
  end
end
