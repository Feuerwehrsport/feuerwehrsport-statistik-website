class Backend::AppointmentsController < Backend::BackendController
  backend_actions clean_cache_disabled: true

  default_form do |f|
    f.input :name
    f.input :dated_at
    f.input :description
    f.association :place, as: :association_select
    f.association :event, as: :association_select
    f.input :disciplines
  end

  filter_index do |by|
    by.scope :event, collection: Event.filter_collection
    by.scope :place, collection: Place.filter_collection
  end

  default_index do |t|
    t.col :name
    t.col :dated_at
    t.col :place, sortable: { place: :name }
    t.col :event, sortable: { event: :name }
  end

  default_show do |t|
    t.col :name
    t.col :dated_at
    t.col :place
    t.col :event
    t.col :creator
  end
end
