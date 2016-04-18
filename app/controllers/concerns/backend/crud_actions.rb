module Backend
  module CRUDActions
    extend ActiveSupport::Concern
    include ResourceAccessor
    
    included do
      before_action :assign_instance, only: [:show, :edit, :update, :destroy]
      before_action :new_instance, only: [:new, :create]
    end

    def new
    end

    def create
      assign_attributes
      if save_instance
        after_create_success 
      else
        render action: :new
      end
    end

    def index
      authorize!(:index, resource_class)
      self.resource_collection = collection_for_index
      @page_title = "Übersicht #{resource_class.model_name.human(count: 0)}"
      @index_columns = index_columns(resource_class)
    end

    def show
      @associations = resource_class.reflect_on_all_associations.select { |a| a.macro == :has_many }.map do |association|
        association = resource_instance.send(association.name)
        association.is_a?(ApplicationCollectionDecorator) ? association.object : association
      end.reject do |association|
        association.new.is_a?(ActiveRecord::View) rescue true
      end
    end

    def edit
    end

    def update
      assign_attributes
      if save_instance
        flash[:success] = t('scaffold.updated')    
        redirect_to [:backend, resource_instance]    
      else
        render action: :edit
      end
    end

    def destroy
      begin
        destroy_instance
        flash[:success] = t('scaffold.deleted') 
        redirect_to action: :index
      rescue ActiveRecord::DeleteRestrictionError => e
        flash[:danger] = e.message
        redirect_to [:backend, resource_instance]
      end
    end

    protected

    def after_create_success
      flash[:success] = t('scaffold.created')
      redirect_to [:backend, resource_instance]
    end

    def save_instance
      saved = resource_instance.save
      clean_cache_and_build_new if saved
      saved
    end

    def destroy_instance
      destroyed = resource_instance.destroy
      clean_cache_and_build_new if destroyed
      destroyed
    end

    def accessible_collection
      resource_class.accessible_by(current_ability, :index)
    end

    def collection_for_index
      collection = accessible_collection
      if resource_class.respond_to?(:search) and params[:search].present?
        collection = collection.search(params[:search])
      end
      collection = collection.index_order if resource_class.respond_to? :index_order
      collection.paginate(page: params[:page], per_page: 20)
    end

    def assign_attributes
      self.resource_instance.assign_attributes(permitted_attributes)
    end

    def assign_instance
      self.resource_instance = accessible_collection.find(params[:id])
      @resource_instance_decorated = resource_instance.decorate
      @page_title = "#{resource_class.model_name.human} - #{@resource_instance_decorated}"
    end

    def build_instance
      resource_class.new
    end

    def new_instance
      self.resource_instance = build_instance
      @resource_instance_decorated = resource_instance.decorate
      @page_title = "#{resource_class.model_name.human}"
    end
  end
end