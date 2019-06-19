require 'rails_helper'

RSpec.describe FeuerwehrsportStatistik, type: :model do
  let(:all_tables) { ActiveRecord::Base.connection.tables.map(&:to_sym) }
  let(:exclude_tables) { Rails.root.join('config', 'dump_exclude_tables').read.split("\n").map(&:to_sym) }
  let(:dump_tables) do
    %i[
      appointments
      ar_internal_metadata
      bla_badges
      competition_files
      competitions
      entity_merges
      events
      federal_states
      group_score_categories
      group_score_types
      group_scores
      links
      nations
      news_articles
      people
      person_participations
      person_spellings
      places
      schema_migrations
      score_types
      scores
      series_assessments
      series_cups
      series_participations
      series_rounds
      team_spellings
      teams
    ]
  end

  it 'exclude tables' do
    expect(all_tables - exclude_tables).to match_array(dump_tables)
  end
end
