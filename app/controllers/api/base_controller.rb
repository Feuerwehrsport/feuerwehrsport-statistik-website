module API
  class BaseController < ApplicationController
    include LoginActions
    include SerializerSupport
    rescue_from CanCan::AccessDenied do |exception| 
      failed(message: exception.message)
    end
    respond_to :json

    protected

    def success(hash={})
      respond_with(hash)
    end

    def failed(hash={})
      respond_with({message: failed_message}.merge(hash).merge(success: false))
    end

    def respond_with(hash={})
      render json: handle_serializer(respond_defaults.merge(hash))
    end

    private

    def failed_message
      "Something went wrong"
    end

    def respond_defaults
      hash = { success: true, login: false }
      if login_status
        hash[:login] = true
        hash[:current_user] = UserSerializer.new(current_user)
      end
      hash
    end

    def self.current_controller_namespace
      "api"
    end
  end
end