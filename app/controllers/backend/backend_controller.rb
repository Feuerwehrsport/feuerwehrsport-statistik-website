module Backend
  class BackendController < ApplicationController
    protect_from_forgery with: :exception
    before_action do
      authorize!(:logout, AdminUser)
    end

    protected

    def current_user
      current_admin_user
    end

    def self.current_controller_namespace
      "backend"
    end
  end
end