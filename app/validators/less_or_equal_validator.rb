# frozen_string_literal: true

class LessOrEqualValidator < LessValidator
  protected

  def operator
    :<=
  end

  def message_key
    :must_be_less_or_equal_than
  end
end
