# frozen_string_literal: true

class GreaterOrEqualValidator < LessValidator
  protected

  def operator
    :>=
  end

  def message_key
    :must_be_greater_or_equal_than
  end
end
