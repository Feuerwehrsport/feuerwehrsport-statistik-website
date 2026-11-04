# frozen_string_literal: true

# Serializes like the API does (SerializerSupport: decorate -> to_serializer -> render json:),
# so these specs stay valid if active_model_serializers is replaced.
module SerializerSpecHelper
  def api_json(record)
    object = record.respond_to?(:decorate) ? record.decorate : record
    object = object.to_serializer if object.respond_to?(:to_serializer)
    JSON.parse(object.to_json, symbolize_names: true)
  end

  def serializer_json(serializer_class, record)
    JSON.parse(serializer_class.new(record.decorate).to_json, symbolize_names: true)
  end
end
