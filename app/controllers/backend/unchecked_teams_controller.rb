# frozen_string_literal: true

class Backend::UncheckedTeamsController < Backend::BackendController
  backend_actions
  map_support_at :show

  default_form do |f|
    f.input :name
    f.input :shortcut
    f.input :status, as: :radio_buttons, collection: { 'Team' => 'team', 'Feuerwehr' => 'fire_station' }
    f.input :checked_at, html5: true
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
