# frozen_string_literal: true

module DestroyConfirmation
  extend ActiveSupport::Concern

  def destroy
    if params[:confirm] == '1' || depending_associations.empty?
      super
    else
      render :confirm_destroy
    end
  end

  private

  def depending_associations
    @depending_associations ||= depending_association_names(resource.class).filter_map do |assoc_name|
      collection = resource.send(assoc_name)
      next if collection.empty?

      {
        collection: collection.decorator_class? ? collection.decorate : collection,
        fields: fields(collection),
        field_names: field_names(collection),
      }
    end
  end

  def depending_association_names(reflected_class)
    reflections = reflected_class.reflections.map do |name, reflection|
      options = reflection.options || {}
      if options[:dependent] == :destroy
        name
      elsif options[:dependent] != :nullify && !reflection.is_a?(ActiveRecord::Reflection::BelongsToReflection)
        raise "Missing dependent option for assocation #{name}"
      end
    end
    reflections.compact
  end

  def fields(_assocation)
    %i[to_s created_at updated_at]
  end

  def field_names(assocation)
    klass = assocation.klass
    fields(assocation).map do |field|
      if field == :to_s
        klass.model_name.human(count: 2)
      else
        klass.human_attribute_name(field)
      end
    end
  end
end
