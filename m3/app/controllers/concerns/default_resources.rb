# frozen_string_literal: true

module DefaultResources
  extend ActiveSupport::Concern

  included do
    attr_accessor :form_resource

    helper_method :resource_class, :form_resource
  end

  protected

  def collection_name
    resource_name.pluralize
  end

  def collection
    instance_variable_get("@#{collection_name}")
  end

  def collection=(collection)
    instance_variable_set("@#{collection_name}", collection)
  end

  def resource_name
    resource_class.name.demodulize.underscore
  end

  def resource
    instance_variable_get("@#{resource_name}")
  end

  def resource=(resource)
    instance_variable_set("@#{resource_name}", resource)
  end

  def resource_class
    controller_path.classify.constantize
  end

  def find_collection
    base_collection
  end

  def base_collection
    resource_class.all
  end

  def build_resource
    resource_class.new
  end

  def find_resource
    base_collection.find_by!(resource_class.param_column_name => params[:id])
  end
end
