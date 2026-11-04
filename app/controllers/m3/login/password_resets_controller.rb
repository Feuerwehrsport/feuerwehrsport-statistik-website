# frozen_string_literal: true

class M3::Login::PasswordResetsController < ApplicationController
  default_actions :new, :create, :edit, :update

  form_for :new, :create do |f|
    f.input :email_address, required: true
  end

  form_for :edit, :update do |f|
    f.input :password, required: true
    f.input :password_confirmation, required: true
  end

  def index; end

  protected

  def find_resource
    resource_class.find(params[:id])
  end

  def collection_redirect_url
    Rails.application.config.m3.session.login_url
  end

  def after_create
    LoginMailer.with(login: form_resource.login).password_reset.deliver_later
    redirect_to return_page_or_url(action: :index)
  end

  def after_update
    flash[:info] = I18n.t('m3.login.password_resets.update_success')
    super
  end
end
