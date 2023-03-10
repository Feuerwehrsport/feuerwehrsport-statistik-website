# frozen_string_literal: true

module M3::FormObjectAssociations
  extend ActiveSupport::Concern

  ReflectionDummy = Struct.new(:macro, :name, :class_name, :options) do
    def klass
      @klass ||= class_name.constantize
    end

    def collection?
      options[:collection]
    end

    def polymorphic?
      false
    end
  end

  class_methods do
    def reflections
      @_reflections ||= {}.with_indifferent_access
      if superclass < M3::FormObject
        superclass.reflections.merge(@_reflections)
      else
        @_reflections
      end
    end

    def reflect_on_association(association)
      reflections[association]
    end

    def belongs_to(accessor, id_accessor: "#{accessor}_id", class_name: accessor.to_s.classify)
      attr_reader accessor, id_accessor

      define_method("#{accessor}=") do |record|
        instance_variable_set("@#{accessor}", record)
        instance_variable_set("@#{id_accessor}", record.try(:id))
      end

      define_method("#{id_accessor}=") do |record_id|
        instance_variable_set("@#{id_accessor}", record_id)
        instance_variable_set("@#{accessor}", class_name.constantize.find_by(id: record_id))
      end

      reflections
      @_reflections[accessor] = ReflectionDummy.new(:belongs_to, accessor, class_name, collection: false)
    end
  end
end
