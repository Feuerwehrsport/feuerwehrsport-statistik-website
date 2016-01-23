module Backend
  class BackendController < ApplicationController
    before_action :authenticate_admin_user!
    before_action :ensure_user_signed_in
    protect_from_forgery with: :exception

    protected

    def current_user
      current_admin_user
    end

    def self.current_controller_namespace
      "backend"
    end

    private

    def ensure_user_signed_in
      unless admin_user_signed_in?
        redirect_to new_admin_user_session_path
      end
    end
  end
end