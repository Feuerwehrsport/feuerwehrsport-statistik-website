class Backend::BLA::BadgesController < Backend::BackendController
  backend_actions
  collection_actions :generate, :index, :new

  default_form do |f|
    f.association :person, as: :association_select
    f.input :year
    f.input :status, as: :radio_buttons
    f.association :hl_score, as: :association_select
    f.input :hl_time
    f.association :hb_score, as: :association_select
    f.input :hb_time
  end

  filter_index do |by|
    by.scope :person, collection: Person.filter_collection, label_method: :searchable_name
    by.scope :year, collection: Year.all.map(&:to_i), hidden: true
  end

  default_index do |t|
    t.col :person, sortable: { person: :last_name }
    t.col :status
    t.col :year
  end
end
