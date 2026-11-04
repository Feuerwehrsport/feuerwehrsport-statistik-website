# frozen_string_literal: true

class FutureTimeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless !(value.is_a?(Time) || value.is_a?(Date)) || value < Time.current

    record.errors.add(attribute, :must_be_future_time)
  end
end
