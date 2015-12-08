module API
  class BaseController < ApplicationController
    respond_to :json

    protected

    def respond_defaults
      {
        success: true,
        login: login_status,
      }
    end

    def respond_with(hash={})
      render json: respond_defaults.merge(hash)
    end

    def login_status
      session[:user_id].present? && User.find_by_id(session[:user_id]).present?
    end

    def success(hash={})
      respond_with(hash)
    end

    def failed(hash={})
      respond_with(hash.merge(success: false, message: failed_message))
    end

    def failed_message
      "Something went wrong"
    end
  end
end