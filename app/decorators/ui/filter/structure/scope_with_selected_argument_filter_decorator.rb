# frozen_string_literal: true

class Ui::Filter::Structure::ScopeWithSelectedArgumentFilterDecorator <
  Ui::Filter::Structure::SingleArgumentFilterDecorator
  def filter_collection(collection, _resource_class)
    collection.send(name, argument)
  end

  # memoized: the select compares every option with it (e.g. ~2.500 competitions)
  def argument
    return @argument if defined?(@argument)

    id = super
    @argument = if options[:argument_finder].respond_to?(:call)
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
