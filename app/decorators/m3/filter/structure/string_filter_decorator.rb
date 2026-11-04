# frozen_string_literal: true

class M3::Filter::Structure::StringFilterDecorator < M3::Filter::Structure::SingleArgumentFilterDecorator
  def filter_collection(collection, resource_class)
    if options[:scope].present?
      collection.public_send(options[:scope], argument)
    else
      columns = options[:columns] || [name]
      collection, columns = columns_to_sql(columns, collection, resource_class)
      where = columns.map { |column| "#{column} ILIKE ?" }.join(' OR ')
      collection.where(where, *columns.map { |_c| "%#{argument}%" })
    end
  end

  def columns_to_sql(columns_or_column, collection, resource_class)
    columns = columns_or_column.is_a?(Array) ? columns_or_column : [columns_or_column]
    columns = columns.map do |column|
      if column.is_a?(Hash)
        inner = []
        column.each do |key, values|
          values = [values] unless values.is_a?(Array)
          values.each do |value|
            table = resource_class.reflections[key.to_s].table_name
            collection = collection.joins(key)
            inner << "\"#{table}\".\"#{value}\""
          end
        end
        inner
      else
        "\"#{resource_class.table_name}\".\"#{column}\""
      end
    end
    [collection, columns.flatten]
  end
end
