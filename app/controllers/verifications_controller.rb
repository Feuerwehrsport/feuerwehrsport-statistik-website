# frozen_string_literal: true

class VerificationsController < ApplicationController
  def verify
    login = Login.find_by_token_for(:verification, params[:token])
    if login
      login.verify!
      flash[:info] = 'E-Mail-Adresse erfolgreich verifiziert'
    else
      flash[:alert] = 'Der Link ist ungültig oder wurde bereits verwendet.'
    end
    redirect_to new_session_path
  end
end
