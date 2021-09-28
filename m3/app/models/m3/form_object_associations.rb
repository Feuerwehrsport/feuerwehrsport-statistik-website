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

    def belongs_to(accessor, id_accessor: "#{accessor}_id", class_name: accessor.to_s.classify, inverse_of: nil)
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

    def accepts_nested_attributes_for(association)
      klass = reflections[association].klass
      define_method("#{association}_attributes=") do |attributes|
        send("#{association}=", klass.new) if send(association).nil?
        send(association).assign_attributes(attributes)
      end
    end

    def has_many(accessor, accessor_single_name: accessor.to_s.singularize.to_sym,
                 id_accessor: :"#{accessor_single_name}_ids", class_name: accessor_single_name.to_s.classify,
                 dependent: nil)
      attr_reader accessor, id_accessor

      association_class = class_name.constantize

      define_method("#{accessor}=") do |records|
        instance_variable_set("@#{accessor}", records)
        instance_variable_set("@#{id_accessor}", records.map(&:id).map(&:to_i))
      end

      define_method("#{id_accessor}=") do |record_ids|
        instance_variable_set("@#{id_accessor}", record_ids.map(&:to_i))
        instance_variable_set("@#{accessor}", association_class.where(id: record_ids))
      end

      after_initialize do
        send("#{id_accessor}=", []) if send(id_accessor).nil?
      end

      reflections
      @_reflections[accessor] = ReflectionDummy.new(:has_many, accessor, class_name, collection: true)
    end
  end
end
