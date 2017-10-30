class Backend::GroupScoreCategoriesController < Backend::BackendController
  backend_actions

  default_form do |f|
    f.input :name
    f.association :competition
    f.association :group_score_type
  end

  filter_index do |by|
    by.scope :competition, collection: Competition.filter_collection
    by.scope :group_score_type, collection: GroupScoreType.filter_collection, label_method: :searchable_name
  end

  default_index do |t|
    t.col :name
    t.col :competition, sortable: { competition: :date }
    t.col :group_score_type, sortable: false
  end
end
