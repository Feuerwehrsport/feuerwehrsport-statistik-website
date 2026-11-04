# frozen_string_literal: true

# Minimal replacement for active_model_serializers (attributes adapter):
# every listed attribute is read from a serializer method of the same name or from the object.
class ApplicationSerializer
  class_attribute :_attributes, instance_writer: false, default: []

  attr_reader :object

  def self.attributes(*names)
    self._attributes = _attributes + names.map(&:to_sym)
  end

  # finds the serializer for a model class, also for subclasses (e.g. UncheckedTeam -> TeamSerializer)
  def self.for(klass)
    while klass && klass != Object
      serializer = "#{klass.name}Serializer".safe_constantize
      return serializer if serializer.is_a?(Class) && serializer < ApplicationSerializer

      klass = klass.superclass
    end
    nil
  end

  def initialize(object)
    @object = object
  end

  def serializable_hash(*)
    _attributes.index_with { |name| read_attribute(name) }
  end
  alias as_json serializable_hash

  def to_json(*)
    ActiveSupport::JSON.encode(serializable_hash)
  end

  private

  def read_attribute(name)
    own_method?(name) ? public_send(name) : object.public_send(name)
  end

  def own_method?(name)
    self.class.public_method_defined?(name) && !ApplicationSerializer.public_method_defined?(name)
  end
end
