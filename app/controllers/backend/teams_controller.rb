# frozen_string_literal: true

class Backend::TeamsController < Backend::BackendController
  backend_actions

  default_form do |f|
    f.input :name
    f.input :shortcut
    f.input :status, as: :radio_buttons, collection: { 'Team' => 'team', 'Feuerwehr' => 'fire_station' }
    f.input :latitude
    f.input :longitude
    f.input :image
    f.input :state
  end

  filter_index do |by|
    by.scope :person, collection: Person.filter_collection, label_method: :searchable_name
    by.scope :competition, collection: Competition.filter_collection
    by.string :name
  end

  default_index do |t|
    t.col :name
    t.col :shortcut
    t.col :status
    t.col :image
    t.col :state
  end
end
