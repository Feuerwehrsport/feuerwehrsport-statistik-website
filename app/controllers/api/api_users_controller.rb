module API
  class APIUsersController < BaseController
    include CRUD::CreateAction

    def status
      success
    end

    def logout
      reset_session
      success
    end

    protected

    def before_create_success
      session[:api_user_id] = resource_instance.id
      super
    end

    def permitted_attributes
      super.permit(:name, :email_address).merge(request_headers: request.headers)
    end
  end
end
