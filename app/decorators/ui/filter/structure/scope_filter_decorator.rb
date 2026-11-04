# frozen_string_literal: true

class Ui::Filter::Structure::ScopeFilterDecorator < Ui::Filter::Structure::BooleanArgumentFilterDecorator
  def filter_collection(collection, _resource_class)
    collection.send(name)
  end
end
