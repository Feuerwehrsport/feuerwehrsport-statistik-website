# frozen_string_literal: true

class Backend::AdminUsersController < Backend::BackendController
  backend_actions :show, :edit, :update, :index, :destroy, clean_cache_disabled: true

  filter_index do |by|
    by.string :name, columns: { login: :name }
    by.string :email_address, columns: { login: :email_address }
  end

  default_form do |f|
    f.fields_for :login do
      f.input :name
      f.input :new_email_address if current_admin_user == resource
    end
    if can?(:manage, resource_class)
      f.input :role, collection: AdminUser::ROLES
      f.fields_for :login do
        f.input :password
        f.input :verified_at
      end
    end
  end

  default_index do |t|
    t.col :name, sortable: { login: :name }
    t.col :email_address, sortable: { login: :email_address }
    t.col :role
  end

  protected

  def after_update
    if form_resource.login.previous_changes[:changed_email_address].present?
      deliver_later(M3::LoginMailer, :change_email_address, form_resource.login)
      flash[:info] = I18n.t('m3.login.change_email_address.email_sent')
    end
    super
  end
end
