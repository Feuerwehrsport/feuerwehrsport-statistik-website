class AdminUserDecorator < ApplicationDecorator
  include Indexable
  index_columns :id, :email

  def to_s
    email
  end
end
