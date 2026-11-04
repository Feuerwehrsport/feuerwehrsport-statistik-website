# frozen_string_literal: true

class M3::Filter::StructureDecorator < ApplicationDecorator
  include Enumerable

  def filter_collection(collection, resource_class:)
    if collection.is_a?(ActiveRecord::Relation)
      each { |filter| collection = filter.filter_collection(collection, resource_class) if filter.filter? }
    end
    collection
  end

  def filtered?
    any?(&:filter?)
  end

  def each
    object.each { |child| yield(child.decorate) }
  end
end
