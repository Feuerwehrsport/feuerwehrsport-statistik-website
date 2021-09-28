# frozen_string_literal: true

class LessValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    larger_value = record.send(than_attribute)
    valid = true
    valid = !value.nil? unless options[:allow_nil]
    valid = !larger_value.nil? if valid && !options[:allow_nil]
    valid = value.send(operator, larger_value) if valid && value && larger_value
    return if valid

    compared_field = record.class.human_attribute_name(than_attribute)
    record.errors.add(attribute, message_key, compared_field: compared_field)
  end

  protected

  def operator
    :<
  end

  def message_key
    :must_be_less_than
  end

  def than_attribute
    options[:than] || raise(ArgumentError, 'Missing option :than for validator (e.g. less: { than: :larger_value })')
  end
end
