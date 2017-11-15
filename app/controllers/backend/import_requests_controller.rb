class Backend::ImportRequestsController < Backend::BackendController
  backend_actions clean_cache_disabled: true

  default_form do |f|
    f.input :file, as: :file_preview
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
  end

  default_show do |i|
    i.col :file_with_link
    i.col :url_with_link
    i.col :date
    i.col :place, sortable: { place: :name }
    i.col :event, sortable: { event: :name }
    i.col :description
    i.col :edit_user
    i.col :finished_at
  end

  protected

  def build_resource
    super.tap { |r| r.admin_user = current_admin_user }
  end

  def after_create
    deliver_later(ImportRequestMailer, :new_request, resource)
    super
  end
end
