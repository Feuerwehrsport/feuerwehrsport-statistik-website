# frozen_string_literal: true

class GreaterValidator < LessValidator
  protected

  def operator
    :>
  end

  def message_key
    :must_be_greater_than
  end
end
