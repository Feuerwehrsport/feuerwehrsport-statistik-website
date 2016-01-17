module API
  module SerializerSupport
    
    protected

    def handle_serializer(hash)
      hash.each do |key, value|
        hash[key] = handle_value_serializer(value)
      end
    end

    def handle_value_serializer(value)
      value = serializer_for_object(value)
      if value.is_a?(ActiveModel::Serializer)
        value
      elsif value.is_a?(Array) || value.is_a?(ApplicationCollectionDecorator)
        value.map { |e| handle_value_serializer(e) }
      elsif value.is_a?(Hash)
        handle_serializer(value)
      else
        value
      end
    end

    def serializer_for_object(object)
      begin
        if object.is_a?(Draper::Decorator)
          serializer = "#{object.object.class.name}Serializer".constantize
        elsif object.is_a?(ActiveRecord::Base)
          serializer = "#{object.class.name}Serializer".constantize
        else
          return object
        end
        serializer.new(object)
      rescue NameError
        object
      end
    end
  end
end