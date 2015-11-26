module Backend
  class ResourcesController < BackendController
    include ResourceAccess
    before_action :assign_instance, only: [:show, :edit, :update, :destroy]
    before_action :new_instance, only: [:new, :create]

    def new
    end

    def create
      assign_attributes
      if resource_instance.save
        flash[:success] = t('scaffold.created')    
        redirect_to [:backend, resource_instance]    
      else
        render action: :new
      end
    end

    def index
      authorize!(:index, resource_class)
      self.collection_instance = collection_for_index
      @page_title = "Übersicht #{resource_class.model_name.human(count: 0)}"
    end

    def show
      @associations = resource_class.reflect_on_all_associations.select { |a| a.macro == :has_many }.map do |association|
        resource_instance.send(association.name)
      end.reject do |association|
        association.new.is_a?(ActiveRecord::View)
      end
    end

    def edit
    end

    def update
      assign_attributes
      if resource_instance.save
        flash[:success] = t('scaffold.updated')    
        redirect_to [:backend, resource_instance]    
      else
        render action: :edit
      end
    end

    def destroy
      begin
        resource_instance.destroy
        flash[:success] = t('scaffold.deleted') 
        redirect_to action: :index
      rescue ActiveRecord::DeleteRestrictionError => e
        flash[:danger] = e.message
        redirect_to [:backend, resource_instance]
      end
    end

    protected

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
      self.resource_instance = accessible_collection.find(params[:id]).decorate
      @page_title = "#{resource_class.model_name.human} - #{resource_instance}"
    end

    def new_instance
      self.resource_instance = resource_class.new
    end

    def permitted_attributes
      params[resource_name]
    end
  end
end