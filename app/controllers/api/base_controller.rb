module API
  class BaseController < ApplicationController
    before_action :set_resource, only: [:destroy, :show, :update]
    respond_to :json

    # POST /api/{plural_resource_name}
    def create  
      set_resource(resource_class.new(resource_params))

      if get_resource.save
        render :show, status: :created
      else
        render json: get_resource.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/{plural_resource_name}/1
    def destroy  
      get_resource.destroy
      head :no_content
    end

    # GET /api/{plural_resource_name}
    def index  
      plural_resource_name = "@#{resource_name.pluralize}"
      resources = resource_class.where(query_params)
                                .page(page_params[:page])
                                .per(page_params[:page_size])

      instance_variable_set(plural_resource_name, resources)
      respond_with instance_variable_get(plural_resource_name)
    end

    # GET /api/{plural_resource_name}/1
    def show  
      respond_with get_resource
    end

    # PATCH/PUT /api/{plural_resource_name}/1
    def update  
      if get_resource.update(resource_params)
        render :show
      else
        render json: get_resource.errors, status: :unprocessable_entity
      end
    end  

    private

    def get_resource
      instance_variable_get("@#{resource_name}")
    end

    def query_params
      {}
    end

    def page_params
      params.permit(:page, :page_size)
    end

    def resource_class
      @resource_class ||= resource_name.classify.constantize
    end

    def resource_name
      @resource_name ||= self.controller_name.singularize
    end

    def resource_params
      @resource_params ||= self.send("#{resource_name}_params")
    end

    def set_resource(resource = nil)
      resource ||= resource_class.find(params[:id])
      instance_variable_set("@#{resource_name}", resource)
    end
  end
end