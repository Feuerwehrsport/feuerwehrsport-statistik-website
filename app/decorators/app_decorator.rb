# frozen_string_literal: true

class AppDecorator < ApplicationDecorator
  include DisciplineNamesAndImages
  include GenderNames

  def self.localizes_gender
    define_method :gender_translated do
      t("gender.#{object.gender}")
    end

    define_method :gender_symbol do
      t("gender.#{object.gender}_symbol")
    end

    define_method :gender do
      object.gender.try(:to_sym)
    end
  end

  def self.localizes_boolean(*fields)
    fields.each do |field|
      define_method("#{field}_translated") do
        return '' if object.send(field).nil?

        object.send(field) ? 'Ja' : 'Nein'
      end
    end
  end

  def self.localizes(*fields)
    super
    fields.each do |field|
      define_method(:"#{field}_iso") do
        l(object.send(field), format: :iso) if object.send(field)
      end

      define_method(:"#{field}_date_iso") do
        l(object.send(field).to_date, format: :iso) if object.send(field)
      end
    end
  end

  def to_serializer
    object.to_serializer(self)
  end
end
