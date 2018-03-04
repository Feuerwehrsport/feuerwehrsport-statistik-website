class Backend::CompetitionsController < Backend::BackendController
  backend_actions

  default_form do |f|
    f.input :name
    f.input :date
    f.association :place, as: :association_select
    f.association :event, as: :association_select
    f.association :score_type
    f.input :hint_content, as: :wysiwyg
    f.input :scores_for_bla_badge
  end

  filter_index do |by|
    by.scope :event, collection: Event.filter_collection
    by.scope :place, collection: Place.filter_collection
    by.scope :score_type, collection: ScoreType.filter_collection
    by.scope :team, collection: Team.filter_collection
  end

  default_index do |t|
    t.col :name
    t.col :date
    t.col :place, sortable: { place: :name }
    t.col :event, sortable: { event: :name }
  end

  default_show do |t|
    t.col :name
    t.col :date
    t.col :place
    t.col :event
    t.col :score_type
    t.col :hint_content
    t.col :scores_for_bla_badge
  end
end
