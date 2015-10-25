module CRUD::IndexAction
  extend ActiveSupport::Concern

  included do
    include CRUD::ResourceAssignment
    before_action :assign_resource_for_index, only: :index
    helper_method :collection_instance_json
  end

  def index
    if collection_instance.respond_to?(:index_order)
      self.collection_instance = collection_instance.index_order
    end
    scope_index_collection
  end

  protected

  def scope_index_collection
    if params[:index_scope] && collection_instance.respond_to?(params[:index_scope])
      self.collection_instance = collection_instance.send(params[:index_scope])
    else
      self.collection_instance = default_index_scope
    end
  end

  def default_index_scope
    collection_instance
  end

  def assign_resource_for_index
    self.collection_instance = index_collection
  end

  def collection_instance_json
    render_to_string json: collection_instance
  end

  def index_collection
    collection = base_collection
    if resource_class.respond_to?(:search) and params[:search].present?
      collection = collection.search(params[:search])
    end
    collection
  end
end