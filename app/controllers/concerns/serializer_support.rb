# frozen_string_literal: true

module SerializerSupport
  protected

  def handle_serializer(hash)
    hash.each do |key, value|
      hash[key] = handle_value_serializer(value)
    end
  end

  def handle_value_serializer(value)
    value = serializer_for_object(value)
    case value
    when Array, ApplicationCollectionDecorator, CollectionDecorator
      value.map { |e| handle_value_serializer(e) }
    when Hash
      handle_serializer(value)
    else
      value
    end
  end

  def serializer_for_object(object)
    object = object.decorate if object.respond_to?(:decorate)
    object.respond_to?(:to_serializer) ? object.to_serializer : object
  end
end
