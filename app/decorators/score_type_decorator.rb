class ScoreTypeDecorator < ApplicationDecorator
  include Indexable
  index_columns :id, :description

  def to_s
    description
  end

  def description
    "#{people}/#{run}/#{score}"
  end
end
