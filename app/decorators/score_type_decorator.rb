class ScoreTypeDecorator < AppDecorator
  def to_s
    description
  end

  def description
    "#{people}/#{run}/#{score}"
  end
end
