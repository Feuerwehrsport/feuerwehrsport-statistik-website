# frozen_string_literal: true

# list "Neue Wettkampforte": duplicates (merge) and position of new places
class Backend::UncheckedPlacesController < Backend::BackendController
  include ChangeLogging

  backend_actions

  default_form do |f|
    f.input :name
    f.input :checked_at, html5: true
  end

  default_index do |t|
    t.col :name
  end

  def show_associations?
    false
  end

  # merges the unchecked place into another place (competitions and position are moved)
  def merge
    place = Place.find(params[:id])
    correct_place = Place.find(params[:correct_place_id])
    authorize!(:merge, place)
    authorize!(:merge, correct_place)

    Place.transaction do
      log_change(correct_place, serializer: PlaceSerializer, action: 'merge',
                                before_hash: serialize_for_log(place, PlaceSerializer))
      EntityMerge.merge!(place, correct_place)
    end
    clean_cache
    redirect_to backend_unchecked_places_path, notice: "#{place.name} wurde mit #{correct_place.name} zusammengeführt."
  rescue ActiveRecord::ActiveRecordError => e
    redirect_to backend_unchecked_place_path(place), alert: "Konnte nicht zusammengeführt werden: #{e.message}"
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
