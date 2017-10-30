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
    super.tap { |r| r.assign_attributes(role: :user, login_attributes: { website: m3_website }) }
  end

  def after_create
    flash[:success] = t3('.registered')
    deliver_later(M3::LoginMailer, :verify, form_resource.login)
    M3::Login::Session.new(session: session, website: m3_website, login: form_resource.login).save(validate: false)
    redirect_to backend_root_path
  end
end
