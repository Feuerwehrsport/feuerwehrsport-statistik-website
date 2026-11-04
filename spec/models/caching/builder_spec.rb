# frozen_string_literal: true

require 'rails_helper'

describe Caching::Builder do
  let!(:person) { create(:person) }
  let!(:female_person) { create(:person, :female) }
  let!(:team) { create(:team) }
  let!(:competition) { create(:competition) }
  let!(:other_competition) { create(:competition, name: 'Zweiter Lauf') }
  let(:la_category) { create(:group_score_category, competition:) }
  let(:fs_category) do
    create(:group_score_category, competition:, group_score_type: create(:group_score_type, discipline: 'fs'))
  end

  before do
    create(:score, :hb, person:, team:, competition:)
    create(:score, :hb, person:, team:, competition:, time: 2000)
    create(:score, :hl, person:, team:, competition:)
    create(:score, :hb, person:, team: nil, competition: other_competition)
    create(:score, single_discipline: create(:single_discipline, :hb_female), person: female_person, team:,
                   competition:)

    la_score = create(:group_score, team:, group_score_category: la_category)
    create(:group_score, team:, team_number: 2, group_score_category: la_category)
    create(:group_score, team:, gender: :female, group_score_category: fs_category, run: 'A')
    create(:person_participation, person:, group_score: la_score)
  end

  it 'updates cached counts and starts html preloader' do
    expect { described_class.perform_now }.to have_enqueued_job(Caching::HtmlPreLoader)

    person.reload
    expect(person.hb_count).to eq 3
    expect(person.hl_count).to eq 1
    expect(person.la_count).to eq 1
    expect(person.fs_count).to eq 0
    expect(person.gs_count).to eq 0
    expect(female_person.reload.hb_count).to eq 1

    competition.reload
    expect(competition.hb_male).to eq 2
    expect(competition.hb_female).to eq 1
    expect(competition.hl_male).to eq 1
    expect(competition.hl_female).to eq 0
    expect(competition.la_male).to eq 2
    expect(competition.la_female).to eq 0
    expect(competition.fs_female).to eq 1
    expect(competition.fs_male).to eq 0
    expect(competition.gs).to eq 0
    # team 1 male, team 2 male, team 1 female
    expect(competition.teams_count).to eq 3
    expect(competition.people_count).to eq 2

    other_competition.reload
    expect(other_competition.hb_male).to eq 1
    expect(other_competition.teams_count).to eq 0
    expect(other_competition.people_count).to eq 1

    team.reload
    expect(team.competitions_count).to eq 1
    expect(team.members_count).to eq 2
  end

  it 'removes waiting jobs of the same class' do
    SolidQueue::Job.create!(queue_name: 'default', class_name: described_class.name, arguments: {})
    other_job = SolidQueue::Job.create!(queue_name: 'default', class_name: 'Caching::HeavyBuilder', arguments: {})

    described_class.perform_now

    expect(SolidQueue::Job.all).to eq [other_job]
  end
end
