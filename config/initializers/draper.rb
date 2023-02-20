# frozen_string_literal: true

class Draper::Decorator
  def self.collection_decorator_class
    name = collection_decorator_name
    name.constantize
  rescue NameError => e
    raise if name && !e.missing_name?(name)

    ::CollectionDecorator
  end
end
