class TeamDecorator < ApplicationDecorator
  include Indexable
  index_columns :id, :name

  delegate :to_s, to: :name

  def full_name
    name
  end
end
