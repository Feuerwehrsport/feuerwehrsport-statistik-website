class APIUserDecorator < ApplicationDecorator
  def to_s
    name
  end
end
