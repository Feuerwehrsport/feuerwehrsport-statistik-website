# frozen_string_literal: true

class Backend::NationsController < Backend::BackendController
  backend_actions

  default_form do |f|
    f.input :name
    f.input :iso
  end

  default_index do |t|
    t.col :name
    t.col :iso
  end
end
