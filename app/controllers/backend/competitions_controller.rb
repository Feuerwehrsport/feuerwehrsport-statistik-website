# frozen_string_literal: true

class Backend::CompetitionsController < Backend::BackendController
  backend_actions

  default_form do |f|
    f.input :name
    f.input :date
    f.association :place, as: :association_select
    f.association :event, as: :association_select
    f.association :score_type
    f.input :hint_content, as: :wysiwyg

    f.input :hb_male_for_bla_badge
    f.input :hl_male_for_bla_badge
    f.input :hb_female_for_bla_badge
    f.input :hl_female_for_bla_badge
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

    t.col :hb_male_for_bla_badge
    t.col :hl_male_for_bla_badge
    t.col :hb_female_for_bla_badge
    t.col :hl_female_for_bla_badge
  end
end
