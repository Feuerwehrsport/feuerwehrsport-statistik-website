module ResourceAccess
  def resource_instance=(instance)
    instance_variable_set("@#{resource_name}", instance)
  end

  def resource_instance
    instance_variable_get("@#{resource_name}")
  end

  def collection_instance=(instance)
    instance_variable_set("@#{resource_name.to_s.pluralize}", instance)
  end

  def collection_instance
    instance_variable_get("@#{resource_name.to_s.pluralize}")
  end

  def resource_class
    controller_path.classify.constantize
  end
  
  def resource_name
    controller_path.singularize.underscore.gsub('/', '_')
  end
end