class Backend::Pdf2Table::EntriesController < Backend::BackendController
  backend_actions :new, :create, :show, :index, :destroy,
                  clean_cache_disabled: true, disable_show_associations: true, disable_logging: true

  default_form do |f|
    f.input :pdf
  end

  default_index do |i|
    i.col :to_s, sortable: :created_at
    i.col :finished_at
    i.col :success_translated, sortable: :success
    i.col(:admin_user) if can?(:manage, Pdf2Table::Entry)
  end

  def index
    redirect_to(action: :new) if collection.blank?
    super
  end

  protected

  def build_resource
    super.tap { |r| r.admin_user = current_admin_user }
  end

  def after_create
    Pdf2Table::Worker.enqueue
    super
  end
end
