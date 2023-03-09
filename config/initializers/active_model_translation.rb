# frozen_string_literal: true

require_dependency 'active_model/translation'

module ActiveModel::Translation
  def human_collection(attribute, options = {})
    parts     = attribute.to_s.split('.')
    attribute = parts.pop
    namespace = parts.join('/') unless parts.empty?
    attributes_scope = "#{i18n_scope}.collections"

    if namespace
      defaults = lookup_ancestors.map do |klass|
        :"#{attributes_scope}.#{klass.model_name.i18n_key}/#{namespace}.#{attribute}"
      end
      defaults << :"#{attributes_scope}.#{namespace}.#{attribute}"
    else
      defaults = lookup_ancestors.map do |klass|
        :"#{attributes_scope}.#{klass.model_name.i18n_key}.#{attribute}"
      end
    end

    defaults << :"collections.#{attribute}"
    defaults << options.delete(:default) if options[:default]

    key = defaults.shift
    options[:default] = defaults
    items = I18n.t(key, **options)
    if items.is_a?(Array) && items.first.is_a?(Hash)
      items = items.inject({}) { |hash, item| hash.merge!(item.keys.first => item.values.first) }
    end
    items
  end

  def human_collection_options(attribute, options = {})
    sorted = options.delete(:sorted) || false
    collection = human_collection(attribute, options)
    collection = collection.sort_by(&:last).to_h if sorted
    collection.invert
  end
end
