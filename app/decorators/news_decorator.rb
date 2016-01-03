class NewsDecorator < ApplicationDecorator
  include Indexable
  index_columns :id, :title

  decorates_association :admin_user
  decorates_association :next
  decorates_association :previous

  def to_s
    title
  end
end
