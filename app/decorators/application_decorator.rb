# frozen_string_literal: true

class ApplicationDecorator < Draper::Decorator
  def self.formats_currency(*fields, fallback: nil)
    fields.each do |field|
      define_method(field) do
        val = object.send(field)
        val.present? ? h.number_to_currency(val) : fallback
      end
    end
  end

  def self.formats_text(*fields, fallback: nil)
    fields.each do |field|
      define_method(field) do
        val = object.send(field)
        val.present? ? h.simple_format(val) : fallback
      end
    end
  end

  def self.localizes(*fields, fallback: nil)
    fields.each do |field|
      define_method(field) do
        val = object.send(field)
        val ? l(val) : fallback
      end

      define_method(:"#{field}_date") do
        val = object.send(field)
        val ? l(val.to_date) : fallback
      end
    end
  end

  def self.localizes_boolean(*fields)
    fields.each do |field|
      define_method(field) do
        object.send(field) ? t('yes') : t('no')
      end
    end
  end

  def self.resolves_locale_dependencies(*fields)
    options = fields.extract_options!
    fields.each do |field|
      define_method(field) do
        value = object.send(:"#{field}_#{I18n.locale}")
        value = value.html_safe if options[:html_safe] && value.respond_to?(:html_safe)
        value
      end
    end
  end

  def self.translates_collection_value(*fields)
    fields.each do |field|
      define_method(field) do
        value = object.send(field)
        return unless value.present? && object.class.respond_to?(:human_collection)

        collection = object.class.human_collection(field)
        unless collection.is_a?(Hash)
          raise %(Cannot find translation activerecord.collections.#{field} for class #{object.class.name})
        end

        collection.stringify_keys[value.to_s]
      end
    end
  end

  def self.number_with_delimiter(*fields)
    options = fields.extract_options!
    fields.each do |field|
      define_method(field) do
        h.number_with_delimiter(object.send(field), options) unless object.send(field).nil?
      end
    end
  end

  def self.try_to_decorate(resource)
    if resource.respond_to?(:decorator_class?) && resource.decorator_class?
      resource.decorate
    else
      resource
    end
  end

  delegate_all
  localizes :created_at, :updated_at
  delegate :t, :l, to: :h
end
