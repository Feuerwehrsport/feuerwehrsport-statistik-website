# frozen_string_literal: true

class APIUserDecorator < AppDecorator
  def to_s
    name
  end
end
