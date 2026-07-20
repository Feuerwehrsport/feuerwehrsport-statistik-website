# frozen_string_literal: true

class AdminController < ApplicationController
  before_action :require_admin!

  private

  def require_admin!
    return if current_user&.role == :admin

    raise CanCan::AccessDenied, 'only admin area'
  end

  def redirect_to_domain
    nil
  end
end
