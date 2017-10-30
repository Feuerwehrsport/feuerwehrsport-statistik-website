class Backend::PersonParticipationsController < Backend::BackendController
  backend_actions

  default_form do |f|
    f.association :person, label_method: :full_name
    f.association :group_score
    f.input :position
  end

  filter_index do |by|
    by.scope :group_score, collection: [], hidden: true
    by.scope :person, collection: Person.filter_collection, label_method: :searchable_name
    by.scope :team, collection: Team.filter_collection
  end

  default_index do |t|
    t.col :person, sortable: { person: :last_name }
    t.col :group_score, sortable: false
    t.col :position
  end
end
