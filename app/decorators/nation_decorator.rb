class NationDecorator < ApplicationDecorator
  include Indexable
  index_columns :id, :name

  def to_s
    name
  end
end
