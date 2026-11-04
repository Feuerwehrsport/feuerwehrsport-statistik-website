# frozen_string_literal: true

class TodayOrFutureDateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :must_be_today_or_future_date) if !value.is_a?(Date) || value < Date.current
  end
end
