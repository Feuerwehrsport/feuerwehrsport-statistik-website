class Backend::ScoreTypesController < Backend::BackendController
  backend_actions

  default_form do |f|
    f.input :people
    f.input :run
    f.input :score
  end

  default_index do |t|
    t.col :people
    t.col :run
    t.col :score
  end
end
