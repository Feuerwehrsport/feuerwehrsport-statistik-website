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
end
