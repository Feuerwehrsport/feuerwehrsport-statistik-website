class CompReg::CompRegController < ApplicationController
  include ResourceAccessor

  # before_action :authenticate_admin_user!
  # before_action :ensure_user_signed_in
  protect_from_forgery with: :exception

  protected

  def clean_cache?(action_name)
    false
  end

  def current_user
    current_admin_user
  end
end