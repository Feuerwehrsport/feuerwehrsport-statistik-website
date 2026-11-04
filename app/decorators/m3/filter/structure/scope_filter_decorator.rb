# frozen_string_literal: true

class M3::Filter::Structure::ScopeFilterDecorator < M3::Filter::Structure::BooleanArgumentFilterDecorator
  def filter_collection(collection, _resource_class)
    collection.send(name)
  end
end
