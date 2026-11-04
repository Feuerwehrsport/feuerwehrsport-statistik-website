# frozen_string_literal: true

class M3::Filter::Structure::PresenceFilterDecorator < M3::Filter::Structure::BooleanArgumentFilterDecorator
  def filter_collection(collection, _resource_class)
    collection.where("#{name} IS NOT NULL AND #{name} != ''")
  end
end
