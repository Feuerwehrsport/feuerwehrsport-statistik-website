module API
  class UsersController < BaseController
    def status
      if session[:user_id].present? && User.find(session[:user_id])
        render json: { success: true, login: true }
      else
        render json: { success: true, login: false }
      end
    end
  end
end
