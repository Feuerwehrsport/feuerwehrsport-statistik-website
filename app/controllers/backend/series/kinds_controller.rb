# frozen_string_literal: true

class Backend::Series::KindsController < Backend::BackendController
  backend_actions

  default_form do |f|
    f.input :name
    f.input :slug
  end

  default_index do |t|
    t.col :name
    t.col :slug
  end
end
