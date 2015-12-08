module API
  class UsersController < BaseController
    include CRUD::CreateAction

    def status
      respond_with
    end

    protected

    def before_create_success
      session[:user_id] = resource_instance.id
      super
    end

    def permitted_attributes
      super.permit(:name, :email_address).merge(request_headers: request.headers)
    end
  end
end
