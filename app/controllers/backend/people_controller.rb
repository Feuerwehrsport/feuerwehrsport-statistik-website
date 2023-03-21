# frozen_string_literal: true

class Backend::PeopleController < Backend::BackendController
  backend_actions

  default_form do |f|
    f.input :first_name
    f.input :last_name
    f.input :gender, collection: %i[male female]
    f.association :nation
    f.input :ignore_bla_untill_year
  end

  filter_index do |by|
    by.scope :nation, collection: Nation.filter_collection
    by.scope :team, collection: Team.all.filter_collection
  end

  default_index do |t|
    t.col :first_name
    t.col :last_name
    t.col :gender
    t.col :nation, sortable: { nation: :name }
  end
end
