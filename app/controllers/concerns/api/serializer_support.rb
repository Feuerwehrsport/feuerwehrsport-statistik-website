module API
  module SerializerSupport
    
    protected

    def handle_serializer(hash)
      hash.each do |key, value|
        hash[key] = handle_value_serializer(value)
      end
    end

    def handle_value_serializer(value)
      if value.is_a?(Draper::Decorator)
        begin
          serializer = "#{value.object.class.name}Serializer".constantize
          serializer.new(value)
        rescue NameError
          value
        end
      elsif value.is_a?(ActiveRecord::Base)
        begin
          serializer = "#{value.class.name}Serializer".constantize
          serializer.new(value)
        rescue NameError
        end
      elsif value.is_a?(Array) || value.is_a?(ApplicationCollectionDecorator)
        value.map { |e| handle_value_serializer(e) }
      elsif value.is_a?(Hash)
        handle_serializer(value)
      else
        value
      end
    end
  end
end