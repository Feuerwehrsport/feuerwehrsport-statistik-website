# frozen_string_literal: true

class M3::Login::BasesController < ApplicationController
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

  def after_create
    LoginMailer.with(login: form_resource).verify.deliver_later
    super
  end
end
