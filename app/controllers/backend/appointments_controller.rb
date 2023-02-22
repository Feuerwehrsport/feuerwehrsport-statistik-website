# frozen_string_literal: true

class Backend::AppointmentsController < Backend::BackendController
  backend_actions clean_cache_disabled: true

  default_form do |f|
    f.input :name
    f.input :dated_at, html5: true
    f.input :description
    f.input :place
    f.association :event, as: :association_select
    f.input :disciplines
  end

  filter_index do |by|
    by.scope :event, collection: Event.filter_collection
  end

  default_index do |t|
    t.col :name
    t.col :dated_at
    t.col :place
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
