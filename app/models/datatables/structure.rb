class Datatables::Structure < M3::Index::Structure
  def klass
    options[:klass]
  end

  def col(name, options = {}, &block)
    push(Datatables::Field.new(name, field_options.merge(options), &block))
  end

  def search(collection, search_string)
    return collection if search_string.strip.blank?

    search_string = "%#{search_string.strip}%"

    query = []
    each do |field|
      next if field.options[:searchable].blank?

      searchables = field.options[:searchable]
      searchables = [searchables] unless searchables.is_a?(Array)
      searchables.each_with_index do |searchable, index|
        if searchable.is_a?(Hash)
          association = searchable.keys.first
          column = searchable.values.first
          table = klass.reflections[association.to_s].table_name
          join_key = klass.reflections[association.to_s].foreign_key
          collection = collection.joins("LEFT OUTER JOIN \"#{table}\" t#{index} ON \"#{klass.table_name}\".#{join_key} = t#{index}.id")
          query.push(klass.send(:sanitize_sql_array, ["t#{index}.\"#{column}\" ILIKE ?", search_string]))
        elsif searchable.is_a?(String)
          query.push(klass.send(:sanitize_sql_array, [searchable, search_string]))
        else
          [searchable].flatten.each do |f|
            query.push(klass.send(:sanitize_sql_array, ["\"#{klass.table_name}\".\"#{f}\" ILIKE ?", search_string]))
          end
        end
      end
    end
    collection.where("(#{query.join(' ) OR (')})")
  end
end
