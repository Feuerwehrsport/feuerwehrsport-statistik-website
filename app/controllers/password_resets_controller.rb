# frozen_string_literal: true

class PasswordResetsController < ApplicationController
  rate_limit to: 5, within: 10.minutes, only: :create, with: -> {
    redirect_to({ action: :new }, alert: 'Zu viele Anfragen. Bitte in einigen Minuten erneut versuchen.')
  }

  # confirmation page after requesting an email
  def index; end

  def new
    @email_address = params[:email_address]
  end

  def edit
    @login = find_login
  end

  def create
    @email_address = params.dig(:password_reset, :email_address).to_s
    login = Login.find_by(email_address: @email_address)
    if login
      LoginMailer.with(login:).password_reset.deliver_later
      redirect_to action: :index
    else
      flash.now[:alert] = 'Zu dieser E-Mail-Adresse gibt es kein Konto.'
      render :new, status: :unprocessable_content
    end
  end

  def update
    @login = find_login
    if @login.reset_password(**params.expect(password_reset: %i[password password_confirmation]).to_h.symbolize_keys)
      flash[:info] = 'Passwort wurde geändert'
      redirect_to new_session_path
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def find_login
    Login.find_by_password_reset_token(params[:id]) || raise(ActiveRecord::RecordNotFound)
  end
end
