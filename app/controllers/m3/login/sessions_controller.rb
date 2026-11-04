# frozen_string_literal: true

require_dependency 'm3'

class M3::Login::SessionsController < ApplicationController
  default_actions :new, :create, :show, :destroy, singleton: true
  before_action :redirect_to_show, only: %i[new create]

  default_form abort_url: -> { url_for(controller: 'm3/login/password_resets', action: :new) } do |f|
    f.input :email_address, required: true
    f.input :password, required: true
  end

  def show
    if current_login.nil?
      redirect_to action: :new
    elsif login_redirect_url
      redirect_to login_redirect_url
    else
      super
    end
  end

  protected

  def build_resource
    resource_class.new(session:)
  end

  def find_resource
    build_resource
  end

  def after_create_failed
    if form_resource.login.present? && form_resource.login_expired?
      redirect_to controller: 'm3/login/expired_logins', action: :new, email_address: form_resource.login.email_address
    elsif form_resource.login.present? && !form_resource.login_verified?
      LoginMailer.with(login: form_resource.login).verify.deliver_later
      flash.now[:info] = I18n.t('m3.login.verifications.resent_verification')
      super
    else
      super
    end
  end

  def after_create
    if session[:requested_url_before_login].present?
      redirect_to session.delete(:requested_url_before_login)
    else
      super
    end
  end

  def login_redirect_url
    url = Rails.application.config.m3.session.login_redirect_url
    if url.blank?
      nil
    elsif url.is_a?(String)
      url
    else
      url_for(url)
    end
  end

  def redirect_to_show
    redirect_to(action: :show) unless current_login.nil?
  end
end
