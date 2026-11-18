# frozen_string_literal: true

class Ui::Filter::Structure::ScopeWithCheckBoxesFilterDecorator < Ui::Filter::Structure::SingleArgumentFilterDecorator
  def filter_collection(collection, _resource_class)
    collection.send(name, argument)
  end

  # memoized: every check box is compared with it
  def argument
    return @argument if defined?(@argument)

    ids = super || []
    @argument = if ids.present? && collection.is_a?(ActiveRecord::Relation)
                  collection.where(collection.klass.param_column_name => ids).load
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
