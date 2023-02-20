# frozen_string_literal: true

class Backend::TeamSpellingsController < Backend::BackendController
  backend_actions

  default_form do |f|
    f.association :team, as: :association_select
    f.input :name
    f.input :shortcut
  end

  filter_index do |by|
    by.scope :team, collection: Team.filter_collection
    by.string :name
    by.string :shortcut
  end

  default_index do |t|
    t.col :name
    t.col :shortcut
    t.col :team, sortable: { team: :name }
  end
end
