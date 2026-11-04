# frozen_string_literal: true

class M3::Index::Structure::FieldDecorator < ApplicationDecorator
  def order_param
    asc? ? "#{name}_desc" : "#{name}_asc"
  end

  def order_collection(collection, resource_class)
    return collection unless sortable? && (asc? || desc?)

    direction = asc? ? 'ASC' : 'DESC'
    nulls = asc? ? 'FIRST' : 'LAST'
    sort_fields = []
    if object.sort_field.is_a?(Hash)
      collection, sort_fields = order_collection_by_hash(collection, resource_class)
    elsif object.sort_field.is_a?(String) && object.sort_field.include?('->>')
      sort_fields = [object.sort_field]
    elsif object.sort_field.is_a?(String)
      sort_fields = ["\"#{object.sort_field}\""]
    else
      [object.sort_field].flatten.each do |field|
        sort_fields << if field.is_a?(String)
                         "\"#{field}\""
                       else
                         "\"#{resource_class.table_name}\".\"#{field}\""
                       end
      end
    end
    order_strings = sort_fields.map do |field|
      "#{field} #{direction} NULLS #{nulls}"
    end
    id_sorting = resource_class.respond_to?(:attribute_names) && resource_class.attribute_names.include?('id')
    order_strings << "\"#{resource_class.table_name}\".id" if id_sorting
    collection.reorder(Arel.sql(order_strings.join(',')))
  end

  def asc?
    h.params[:order] == "#{name}_asc" || (h.params[:order].blank? && default_order == :asc)
  end

  def desc?
    h.params[:order] == "#{name}_desc" || (h.params[:order].blank? && default_order == :desc)
  end

  def sorted?
    asc? || desc?
  end

  def value(resource)
    value = raw_value(resource)
    value = value.count if value.is_a?(CollectionDecorator) || value.is_a?(ActiveRecord::Relation)
    value = value.to_s
    truncate = !value.html_safe? && !export_request? && object.truncate.is_a?(Integer)
    value = value.truncate(object.truncate) if truncate
    value
  end

  def excel_type(resource)
    raw_value(resource).is_a?(String) ? :string : nil
  end

  def excel_style(_resource, styles)
    options[:excel_style].present? ? styles[options[:excel_style]] : nil
  end

  def label
    object.options[:label] || (options[:resource_class].presence || h.resource_class).human_attribute_name(name)
  end

  private

  def export_request?
    @export_request ||= options[:export_request] || begin
      if h.respond_to?(:m3_index_export_formats)
        h.m3_index_export_formats.include?(h.request.format.to_sym)
      else
        false
      end
    end
  end

  def raw_value(resource)
    if object.block.present?
      object.block.call(resource)
    else
      resource.send(object.name)
    end
  end

  def order_collection_by_hash(collection, resource_class)
    association = object.sort_field.keys.first
    column = object.sort_field.values.first
    table = resource_class.reflections[association.to_s].table_name
    join_key = resource_class.reflections[association.to_s].foreign_key
    [
      collection.joins("LEFT OUTER JOIN \"#{table}\" t ON \"#{resource_class.table_name}\".#{join_key} = t.id"),
      ["t.\"#{column}\""],
    ]
  end
end
