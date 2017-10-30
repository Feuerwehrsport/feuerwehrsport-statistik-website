class LinkDecorator < AppDecorator
  decorates_association :linkable

  delegate :label, to: :object

  def to_s
    object.label
  end
end
