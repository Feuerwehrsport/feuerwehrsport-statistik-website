class AdminUsers::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_sign_up_params, only: [:create]
  before_filter :configure_account_update_params, only: [:update]

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def after_sign_up_path_for(resource)
    backend_root_path
  end

  def after_inactive_sign_up_path_for(resource)
    new_admin_user_session_path
  end
end
