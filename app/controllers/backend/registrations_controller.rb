# frozen_string_literal: true

class Backend::RegistrationsController < Backend::BackendController
  backend_actions :new, :create, for_class: AdminUsers::Registration

  default_form do |f|
    f.fields_for :login do
      f.input :name
      f.input :email_address
      f.input :password
      f.input :password_confirmation
    end
  end

  protected

  def build_resource
    super.tap { |r| r.assign_attributes(role: :user) }
  end

  def after_create
    flash[:success] = t3('.registered')
    LoginMailer.with(login: form_resource.login).verify.deliver_later
    M3::Login::Session.new(session: session, login: form_resource.login).save(validate: false)
    if session[:requested_url_before_login].present?
      redirect_to session.delete(:requested_url_before_login)
    else
      redirect_to backend_root_path
    end
  end
end
