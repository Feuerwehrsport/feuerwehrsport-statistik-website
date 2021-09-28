# frozen_string_literal: true

module ActiveRecord::VirtualColumns
  extend ActiveSupport::Concern

  included do
    class_attribute :virtual_columns_hash
    self.virtual_columns_hash = {}.with_indifferent_access
  end

  class_methods do
    def virtual_column(name, type, klass = nil, default = nil)
      cast_type = if klass == Date
                    ActiveRecord::Type::Date.new
                  elsif type == :boolean
                    ActiveRecord::Type::Boolean.new
                  else
                    OpenStruct.new(type: type, klass: klass)
                  end
      column = ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, cast_type)

      virtual_columns_hash[name.to_s] = column
    end

    def columns_hash
      super.merge(virtual_columns_hash)
    end
  end

  def has_attribute?(attr_name)
    super || virtual_columns_hash[attr_name].present?
  end
end
