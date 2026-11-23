# frozen_string_literal: true

class Backend::PlacesController < Backend::BackendController
  backend_actions

  default_form do |f|
    f.input :name
    # empty: the place is in the list "Neue Wettkampforte" again (e.g. to merge it)
    f.input :checked_at, html5: true
  end

  default_index do |t|
    t.col :name
  end
end
