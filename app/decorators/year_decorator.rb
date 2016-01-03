class YearDecorator < ApplicationDecorator
  def to_s
    object.year.to_i.to_s
  end

  def to_i
    object.year.to_i
  end
end
