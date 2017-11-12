class Registrations::BaseController < ApplicationController
  protected

  def current_user
    current_admin_user
  end
end
