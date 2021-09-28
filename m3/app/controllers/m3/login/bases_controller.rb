# frozen_string_literal: true

class M3::Login::BasesController < ApplicationController
  disable_tracking
  default_actions for_class: M3::Login::Base

  default_form do |f|
    f.inputs :user_data do
      f.input :name
    end
    f.inputs :login_data do
      f.input :email_address, required: true
      f.input :password, required: true
      f.input :password_confirmation, required: true
    end
  end

  protected

  def build_resource
    resource_class.new(website: m3_website)
  end

  def after_create
    deliver_later(M3::LoginMailer, :verify, form_resource) if Rails.configuration.m3.login.send_verification_mail
    super
  end
end
