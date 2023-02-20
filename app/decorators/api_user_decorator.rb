# frozen_string_literal: true

class ApiUserDecorator < AppDecorator
  def to_s
    name
  end
end
