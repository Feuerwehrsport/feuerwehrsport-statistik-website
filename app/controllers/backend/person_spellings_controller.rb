class Backend::PersonSpellingsController < Backend::BackendController
  backend_actions

  default_form do |f|
    f.input :first_name
    f.input :last_name
    f.input :gender, collection: %i[male female]
    f.association :person
    f.input :official
  end

  filter_index do |by|
    by.scope :person, collection: Person.filter_collection, label_method: :searchable_name
    by.scope :gender, collection: %i[male female]
    by.scope :official
  end

  default_index do |t|
    t.col :first_name
    t.col :last_name
    t.col :gender
    t.col :person, sortable: { person: :last_name }
    t.col :official
  end
end
