# frozen_string_literal: true

class M3::Index::StructureDecorator < ApplicationDecorator
  include Enumerable

  def order_collection(collection, resource_class:)
    if collection.is_a?(ActiveRecord::Relation)
      each { |field| collection = field.order_collection(collection, resource_class) }
    end
    collection
  end

  def each
    object.each { |child| yield(child.decorate) }
  end
end
