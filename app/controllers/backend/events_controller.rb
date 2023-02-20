# frozen_string_literal: true

class Backend::EventsController < Backend::BackendController
  backend_actions

  default_form do |f|
    f.input :name
  end

  default_index do |t|
    t.col :name
  end
end
