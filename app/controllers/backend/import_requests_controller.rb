class Backend::ImportRequestsController < Backend::BackendController
  backend_actions clean_cache_disabled: true

  default_form do |f|
    f.input :file
    f.input :url
    f.input :date
    f.association :place, collection: Place.filter_collection
    f.association :event, collection: Event.filter_collection
    f.input :description
    if can?(:update, resource)
      f.association :edit_user
      f.input :finished, as: :boolean
    end
  end

  protected

  def clean_cache?(_action_name)
    false
  end

  def build_resource
    super.tap { |r| r.admin_user = current_admin_user }
  end

  def after_create
    deliver_later(ImportRequestMailer, :new_request, resource)
    super
  end
end
