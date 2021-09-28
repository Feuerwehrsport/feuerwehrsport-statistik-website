# frozen_string_literal: true

class M3::Filter::Structure::FilterDecorator < ApplicationDecorator
  def filter_collection(collection, _resource_class)
    collection
  end

  def filter?
    false
  end

  def param_name
    "q[#{inner_param_name}]"
  end

  def inner_param_name
    "#{name}_#{underscore_class_name}"
  end

  def param
    params[:q][inner_param_name] if params[:q]
  end

  def html_id
    inner_param_name.parameterize
  end

  def label
    options[:label].presence || h.resource_class.human_attribute_name(name)
  end

  def to_partial_path
    "filter_#{underscore_class_name}"
  end

  def hidden?
    options[:hidden] || false
  end

  def label_method
    options[:label_method] || :to_s
  end

  protected

  def underscore_class_name
    self.class.name.demodulize.underscore.gsub('_filter_decorator', '')
  end

  def params
    h.params
  end
end
