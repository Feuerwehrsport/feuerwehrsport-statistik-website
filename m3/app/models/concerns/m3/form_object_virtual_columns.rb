# frozen_string_literal: true

module M3::FormObjectVirtualColumns
  extend ActiveSupport::Concern

  included do
    class_attribute :columns_hash
    self.columns_hash = {}.with_indifferent_access
  end

  class_methods do
    def virtual_column(name, type, klass, default = nil)
      columns_hash[name.to_s] = OpenStruct.new(name: name.to_s, type: type, klass: klass, default: default)
    end

    def date_accessor(name, default = nil)
      attr_accessor name

      virtual_column(name, :date, Date, default)
      define_method(:"#{name}=") do |date_or_string|
        if date_or_string.is_a?(Hash) && date_or_string.keys.sort == [1, 2, 3]
          date_or_string = Date.new(date_or_string[1], date_or_string[2], date_or_string[3])
        elsif date_or_string.is_a?(String)
          date_or_string = Date.parse(date_or_string)
        end
        instance_variable_set(:"@#{name}", date_or_string)
      end
    end

    def datetime_accessor(name, default = nil)
      attr_accessor name

      virtual_column(name, :datetime, DateTime, default)
      define_method(:"#{name}=") do |time_or_string|
        if time_or_string.is_a?(Hash) && time_or_string.keys.sort == [1, 2, 3, 4, 5]
          time_or_string = Time.zone.local(
            time_or_string[1], time_or_string[2], time_or_string[3], time_or_string[4], time_or_string[5]
          ).to_datetime
        elsif time_or_string.is_a?(String)
          time_or_string = DateTime.parse(time_or_string)
        end
        instance_variable_set(:"@#{name}", time_or_string)
      end
    end

    def boolean_accessor(name, default = nil)
      virtual_column(name, :boolean, nil, default)
      define_method(name) do
        value = instance_variable_get(:"@#{name}")
        value.nil? ? default : value
      end
      define_method(:"#{name}?") { send(name) }
      define_method(:"#{name}=") do |boolean_or_string|
        value = if boolean_or_string.nil?
                  nil
                elsif boolean_or_string == true || boolean_or_string =~ /\A(true|t|yes|y|1)\z/i
                  true
                elsif boolean_or_string == false || boolean_or_string =~ /\A(false|f|no|n|0)\z/i
                  false
                end
        instance_variable_set(:"@#{name}", value)
      end
    end

    def integer_accessor(name, default = nil)
      attr_accessor name

      virtual_column(name, :integer, nil, default)
      define_method(:"#{name}=") do |number_or_string|
        value = if number_or_string.blank?
                  nil
                else
                  number_or_string.to_i
                end
        instance_variable_set(:"@#{name}", value)
      end
    end

    def decimal_accessor(name, default = nil)
      attr_accessor name

      virtual_column(name, :decimal, nil, default)
      define_method(:"#{name}=") do |number_or_string|
        value = if number_or_string.blank?
                  nil
                else
                  BigDecimal(number_or_string.to_s.tr(',', '.'))
                end
        instance_variable_set(:"@#{name}", value)
      end
    end
  end

  def column_types
    columns_hash
  end

  def type_for_attribute(attr_name)
    column_types[attr_name]
  end

  def column_for_attribute(attr_name)
    column_types[attr_name]
  end

  def has_attribute?(attr_name)
    column_types[attr_name].present?
  end
end
