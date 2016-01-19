class AdminUserDecorator < ApplicationDecorator
  include Indexable
  index_columns :id, :email

  decorates_association :news

  def to_s
    name
  end
end
