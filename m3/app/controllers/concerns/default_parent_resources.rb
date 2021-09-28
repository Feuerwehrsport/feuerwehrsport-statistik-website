# frozen_string_literal: true

module DefaultParentResources
  extend ActiveSupport::Concern

  included do
    helper_method :parent_resource?
    helper_method :parent_resource_class
    helper_method :parent_url
  end

  protected

  def parent_resource?
    false
  end

  def assign_parent_resource; end

  class_methods do
    def belongs_to(parent_class, parent_name: nil, child_name: nil, url: nil, children: nil)
      parent_name ||= parent_class.name.demodulize.underscore

      include ParentMethods

      define_method :parent_resource? do
        true
      end

      define_method :parent_resource_class do
        parent_class
      end

      define_method :parent_resource_name do
        parent_name
      end

      define_method :parent_resource_child_name do
        child_name || resource_class.name.demodulize.underscore.pluralize
      end

      define_method :parent_url do
        if url.is_a?(Proc)
          instance_exec(&url)
        else
          url
        end
      end

      return unless children

      define_method :base_collection do
        if children.is_a?(Proc)
          instance_exec(parent_resource, &children)
        else
          children
        end
      end
    end
  end

  module ParentMethods
    def find_parent_resource
      parent_resource_class.find_by!(parent_resource_class.param_column_name => params["#{parent_resource_name}_id"])
    end

    def parent_resource
      instance_variable_get("@#{parent_resource_name}")
    end

    def parent_resource=(resource)
      instance_variable_set("@#{parent_resource_name}", resource)
    end

    def build_resource
      parent = super
      parent.send("#{parent_resource_name}=", parent_resource)
      parent
    end

    def base_collection
      parent_resource.send(parent_resource_child_name)
    end

    def assign_parent_resource
      self.parent_resource = find_parent_resource if parent_resource?
    end
  end
end
