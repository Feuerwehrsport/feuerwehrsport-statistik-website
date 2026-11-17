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
    include ChangeLogSupport unless for_class < FormObject || disable_logging
    include CleanCacheSupport unless clean_cache_disabled

    collection_actions :live_resource, :index, :new, check_existence: true
    member_actions :live_resource, :show, :edit, :destroy, check_existence: true
  end

  def self.default_show(&)
    define_method(:show_structure) do
      @show_structure ||= Ui::Index::Structure.build(self, &).decorate
    end
  end

  def show_associations?
    true
  end

  def has_many_associations
    return {} unless resource_class.respond_to?(:reflect_on_all_associations)

    associations = {}
    resource_class.reflect_on_all_associations.select { |a| a.macro == :has_many }.map do |association|
      next if association.nested?

      model_name = association.klass.model_name.human(count: :many)
      q = if association.options[:as].present?
            { "#{association.options[:as]}_type_scope": resource_class,
              "#{association.options[:as]}_id_scope": resource.id }
          else
            { "#{resource_name}_scope": resource.id }
          end
      # associations without a backend controller (e.g. SQL views like TeamMember) have no route and are skipped
      url = (begin
        url_for(controller: "backend/#{association.name}", action: :index, q:, only_path: true)
      rescue ActionController::UrlGenerationError
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
