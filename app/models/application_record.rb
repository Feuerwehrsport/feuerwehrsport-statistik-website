# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  include SchemaValidations # to include auto generated validations

  validate :validate_dates

  def validate_dates
    self.class.columns_hash.each do |attribute_name, column|
      next unless column.type.in?(%i[date datetime])

      current = send(attribute_name)
      next if current.nil?
      next unless current.respond_to?(:year)
      next if current.year.in?(1850..2150)

      errors.add(attribute_name, :year_not_valid)
    end
  end

  def to_serializer(object = self)
    klass = ActiveModel::Serializer.get_serializer_for(self.class)
    klass.nil? ? object : klass.new(object)
  end

  def self.jsonb_as_text(field)
    attr_writer "#{field}_text"

    define_method("#{field}_text") do
      instance_variable_get("@#{field}_text") || JSON.pretty_generate(send(field))
    end

    before_validation do
      next if instance_variable_get("@#{field}_text").blank?

      send("#{field}=", JSON.parse(instance_variable_get("@#{field}_text")))
    rescue JSON::ParserError
      errors.add(:"#{field}_text", 'ist kein gültiges JSON')
    end
  end
end
