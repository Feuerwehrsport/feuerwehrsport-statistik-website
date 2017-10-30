class Backend::GroupScoreTypesController < Backend::BackendController
  backend_actions

  default_form do |f|
    f.input :regular
    f.input :name
    f.input :discipline, collection: %i[la gs fs]
  end

  filter_index do |by|
    by.scope :competition, collection: Competition.filter_collection
  end

  default_index do |t|
    t.col :regular
    t.col :name
    t.col :discipline
  end
end
