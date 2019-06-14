class Backend::ImportRequestsController < Backend::BackendController
  backend_actions clean_cache_disabled: true
  skip_before_action :preauthorize_action, only: :decide_login

  default_form do |f|
    f.fields_for :import_request_files do
      f.input :file, as: :file_preview
    end
    f.input :url
    f.input :date
    f.association :place, as: :association_select
    f.association :event, as: :association_select
    f.input :description
    if can?(:update, resource)
      f.association :edit_user, collection: AdminUser.admins.filter_collection
      f.input :finished, as: :boolean
    end
  end

  default_index do |i|
    i.col :date
    i.col :place, sortable: { place: :name }
    i.col :event, sortable: { event: :name }
    i.col :description
    i.col :finished_at
    i.col :created_at
  end

  def new
    form_resource.import_request_files.build
    super
  end

  def decide_login
    redirect_to action: :new if current_login.present?
    session[:requested_url_before_login] = url_for
  end

  protected

  def build_resource
    super.tap { |r| r.admin_user = current_admin_user }
  end

  def after_create
    deliver_later(ImportRequestMailer, :new_request, resource)
    super
  end

  def show_associations?
    false
  end
end
