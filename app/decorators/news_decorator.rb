class NewsDecorator < ApplicationDecorator
  include Indexable
  index_columns :id, :title

  decorates_association :admin_user

  def to_s
    title
  end
end
