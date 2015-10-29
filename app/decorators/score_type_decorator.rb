class ScoreTypeDecorator < ApplicationDecorator
  def to_s
    "#{people}/#{run}/#{score}"
  end
end
