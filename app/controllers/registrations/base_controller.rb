class Registrations::BaseController < ApplicationController
  protected

  def clean_cache?(_action_name)
    false
  end

  def current_user
    current_admin_user
  end
end
