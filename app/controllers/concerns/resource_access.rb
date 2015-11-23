module ResourceAccess
  extend ActiveSupport::Concern
  included do
    helper_method def resource_class
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

  attr_accessor :resource_instance, :collection_instance

  def resource_class
    self.class.resource_class
  end
  
  def resource_name
    resource_class.name.singularize.underscore
  end
end