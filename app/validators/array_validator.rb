# frozen_string_literal: true

class ArrayValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.is_a?(Array)
      record.errors.add(attribute, options[:message] || 'must be an array')
      return
    end

    if options[:min] && value.size < options[:min]
      record.errors.add(attribute, options[:message] || "must contain at least #{options[:min]} element(s)")
    end

    if options[:in] && !value.all? { |v| v.in?(options[:in]) }
      record.errors.add(attribute, options[:message] || "must all in #{options[:in].inspect}")
    end

    return unless options[:of]

    klass = options[:of]

    return if value.all?(klass)

    record.errors.add(attribute, options[:message] || "must contain only #{klass} values")
  end
end
