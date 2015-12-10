module ResourceAccessor
  extend ActiveSupport::Concern
  attr_accessor :resource_instance, :resource_collection

  included do
    helper_method :resource_instance
    helper_method :resource_collection
    helper_method :resource_class
  end

  class_methods do
    def resource_variable_name
      controller_name.singularize
    end

    def resource_class
      begin
        controller_path.classify.constantize
      rescue NameError
        begin
          controller_name.classify.constantize
        rescue NameError
          nil
        end
      end
    end
  end

  def resource_variable_name
    self.class.resource_variable_name
  end

  def resource_class
    self.class.resource_class
  end

  def permitted_attributes
    params.require(resource_variable_name)
  end
end