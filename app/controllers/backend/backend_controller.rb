# frozen_string_literal: true

class Backend::BackendController < ApplicationController
  helper_method :has_many_associations, :belongs_to_associations, :show_associations?

  def self.backend_actions(*action_names)
    options              = action_names.extract_options!
    for_class            = options.delete(:for_class) || controller_path.classify.gsub(/^Backend::/, '').constantize
    clean_cache_disabled = options.delete(:clean_cache_disabled)
    disable_logging = options.delete(:disable_logging)
    options[:for_class] = for_class
    define_method(:show_associations?) { false } if options.delete(:disable_show_associations)
    default_actions(*action_names, **options)
    include SerializerSupport
    include ChangeLogSupport unless for_class < M3::FormObject || disable_logging
    include CleanCacheSupport unless clean_cache_disabled

    collection_actions :live_resource, :index, :new, check_existence: true
    member_actions :live_resource, :show, :edit, :destroy, check_existence: true
  end

  def self.default_show(&)
    define_method(:m3_show_structure) do
      @m3_show_structure ||= M3::Index::Structure.build(self, &).decorate
    end
  end

  def show_associations?
    true
  end

  def has_many_associations
    return {} unless resource_class.respond_to?(:reflect_on_all_associations)

    associations = {}
    resource_class.reflect_on_all_associations.select { |a| a.macro == :has_many }.map do |association|
      collection = resource.send(association.name)
      collection = collection.object if collection.is_a?(ApplicationCollectionDecorator)
      next if association.nested?

      instance = collection.new
      next if begin
      # instance.is_a?(ActiveRecord::View)
      # TODO
      rescue StandardError
        true
      end

      model_name = instance.class.model_name.human(count: :many)
      q = if association.options[:as].present?
            { "#{association.options[:as]}_type_scope": resource_class,
              "#{association.options[:as]}_id_scope": resource.id }
          else
            { "#{resource_name}_scope": resource.id }
          end
      url = (begin
        url_for(controller: "backend/#{association.name}", action: :index, q:)
      rescue StandardError
        nil
      end)
      associations[model_name] = url if url.present?
    end
    associations.with_indifferent_access
  end

  def belongs_to_associations
    return {} unless resource_class.respond_to?(:reflect_on_all_associations)

    associations = {}
    resource_class.reflect_on_all_associations.select { |a| a.macro == :belongs_to }.map do |association|
      associations[association.name] = resource.send(association.name)
    end
    associations.with_indifferent_access
  end
end
