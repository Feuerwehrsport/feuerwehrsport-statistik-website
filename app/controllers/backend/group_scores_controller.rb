# frozen_string_literal: true

class Backend::GroupScoresController < Backend::BackendController
  backend_actions

  default_form do |f|
    f.association :team, as: :association_select
    f.input :team_number
    f.input :gender, collection: %i[male female]
    f.input :time
    f.association :group_score_category, as: :association_select, association: :group_score_category
    f.input :run, collection: %w[A B C]
  end

  filter_index do |by|
    by.scope :competition, collection: Competition.filter_collection
    by.scope :group_score_category, collection: [], hidden: true
    by.scope :group_score_type, collection: GroupScoreType.filter_collection, label_method: :searchable_name
    by.scope :person, collection: [], hidden: true
    by.scope :team, collection: Team.filter_collection
  end

  default_index do |t|
    t.col :competition, sortable: false
    t.col :time
    t.col :team, sortable: { team: :name }
    t.col :team_number
    t.col :discipline, sortable: false
  end
end
