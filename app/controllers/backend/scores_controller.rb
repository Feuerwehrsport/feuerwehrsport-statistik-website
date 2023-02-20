# frozen_string_literal: true

class Backend::ScoresController < Backend::BackendController
  backend_actions

  default_form do |f|
    f.association :person, as: :association_select
    f.association :team, as: :association_select
    f.input :team_number
    f.input :time
    f.input :discipline
    f.association :competition, as: :association_select
  end

  filter_index do |by|
    by.scope :competition, collection: Competition.filter_collection
    by.scope :person, collection: Person.filter_collection, label_method: :searchable_name
    by.scope :team, collection: [], hidden: true
  end

  default_index do |t|
    t.col :person, sortable: { person: :last_name }
    t.col :team, sortable: { team: :name }
    t.col :team_number
    t.col :time
    t.col :discipline
    t.col :competition, sortable: { competition: :date }
  end
end
