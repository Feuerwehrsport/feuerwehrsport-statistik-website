# frozen_string_literal: true

module M3::FormObjectVirtualColumns
  extend ActiveSupport::Concern

  VirtColumn = Struct.new(:name, :type, :klass, :default)

  included do
    class_attribute :columns_hash
    self.columns_hash = {}.with_indifferent_access
  end

  class_methods do
    def virtual_column(name, type, klass, default = nil)
      columns_hash[name.to_s] = VirtColumn.new(name.to_s, type, klass, default)
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
