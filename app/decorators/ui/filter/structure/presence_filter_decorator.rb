# frozen_string_literal: true

class Ui::Filter::Structure::PresenceFilterDecorator < Ui::Filter::Structure::BooleanArgumentFilterDecorator
  def filter_collection(collection, _resource_class)
    collection.where("#{name} IS NOT NULL AND #{name} != ''")
  end
end
