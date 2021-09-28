# frozen_string_literal: true

class M3::Filter::Structure::ScopeWithSelectedArgumentFilterDecorator <
  M3::Filter::Structure::SingleArgumentFilterDecorator
  def filter_collection(collection, _resource_class)
    collection.send(name, argument)
  end

  def argument
    id = super
    if options[:argument_finder].respond_to?(:call)
      options[:argument_finder].call(id)
    elsif id.present? && collection.is_a?(ActiveRecord::Relation)
      collection.find_by!(collection.klass.param_column_name => id)
    elsif id.present? && collection.first.is_a?(Array)
      collection.detect { |pair| pair.second == id }.try(:second)
    else
      id
    end
  end

  def collection
    options[:collection]
  end

  def inner_param_name
    "#{name}_scope"
  end
end
