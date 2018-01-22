class Backend::UncheckedTeamsController < Backend::BackendController
  backend_actions

  default_form do |f|
    f.input :name
    f.input :checked_at
  end

  default_index do |t|
    t.col :name
  end

  def show_associations?
    false
  end

  protected

  def after_update
    if form_resource.checked_at.present?
      redirect_to collection_redirect_url
    else
      super
    end
  end
end
