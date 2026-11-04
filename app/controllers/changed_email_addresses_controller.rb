# frozen_string_literal: true

class ChangedEmailAddressesController < ApplicationController
  before_action :find_login

  def edit; end

  def update
    @login.confirm_email_change!
    flash[:info] = 'E-Mail-Adresse wurde geändert'
    redirect_to(current_login ? backend_root_path : new_session_path)
  end

  private

  def find_login
    @login = Login.where.not(changed_email_address: nil).find_by_token_for(:email_change, params[:id])
    raise ActiveRecord::RecordNotFound if @login.nil?
  end
end
