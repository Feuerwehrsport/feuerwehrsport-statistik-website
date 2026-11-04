# frozen_string_literal: true

class Ui::Filter::Structure::ConfigurableFilterDecorator < Ui::Filter::Structure::FilterDecorator
  def filter?
    options[:filter]
  end

  def to_partial_path
    options[:partial_path]
  end

  def filter_collection(collection, _resource_class)
    block.call(collection)
  end
end
