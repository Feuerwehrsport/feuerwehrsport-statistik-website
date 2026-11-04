# frozen_string_literal: true

class SessionsController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> {
    redirect_to new_session_path, alert: 'Zu viele Anmeldeversuche. Bitte in einigen Minuten erneut versuchen.'
  }

  def show
    redirect_to(current_login ? after_login_url : new_session_path)
  end

  def new
    redirect_to after_login_url if current_login
  end

  def create
    login = Login.authenticate_by(email_address: session_params[:email_address].to_s,
                                  password: session_params[:password].to_s)

    if login.nil?
      render_new_with_alert('E-Mail-Adresse oder Passwort ist falsch.')
    elsif login.expired?
      redirect_to new_expired_login_path(email_address: login.email_address)
    elsif !login.verified?
      LoginMailer.with(login:).verify.deliver_later
      flash.now[:info] = 'Verifizierungs-E-Mail erneut versendet'
      render_new_with_alert('Die E-Mail-Adresse ist noch nicht bestätigt.')
    else
      start_session(login)
      redirect_to session.delete(:requested_url_before_login) || after_login_url
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, notice: 'Sie wurden abgemeldet.'
  end

  private

  def session_params
    params.fetch(:session, {}).permit(:email_address, :password)
  end

  def render_new_with_alert(message)
    @email_address = session_params[:email_address]
    flash.now[:alert] = message
    render :new, status: :unprocessable_content
  end

  def after_login_url
    backend_root_path
  end
end
