# frozen_string_literal: true

class M3::Filter::Structure::ScopeWithCheckBoxesFilterDecorator < M3::Filter::Structure::SingleArgumentFilterDecorator
  def filter_collection(collection, _resource_class)
    collection.send(name, argument)
  end

  def argument
    ids = super || []
    if ids.present? && collection.is_a?(ActiveRecord::Relation)
      collection.where(collection.klass.param_column_name => ids)
    elsif ids.present? && collection.first.is_a?(Array)
      collection.select { |pair| pair.second.to_s.in? ids }.map(&:second)
    else
      ids
    end
  end

  def collection
    options[:collection]
  end

  def inner_param_name
    "#{name}_scope"
  end
end
