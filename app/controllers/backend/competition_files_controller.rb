class Backend::CompetitionFilesController < Backend::BackendController
  backend_actions

  default_form do |f|
    f.association :competition
    f.input :file
    f.input :keys_string
  end

  filter_index do |by|
    by.scope :competition, collection: Competition.filter_collection
  end

  default_index do |t|
    t.col :competition, sortable: { competition: :name }
    t.col :file
    t.col :keys, sortable: :keys_string
  end
end
