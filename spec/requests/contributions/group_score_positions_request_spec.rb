# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contributions::GroupScorePositions', login: :api do
  let!(:group_score) { create(:group_score) }
  let!(:nation) { create(:nation) }
  let!(:known) { create(:person, first_name: 'Karl', last_name: 'Bekannt') }
  let(:path) { "/contributions/group_scores/#{group_score.id}/positions/2" }

  before do
    other_run = create(:group_score, team: group_score.team, time: 2500)
    create(:person_participation, person: known, group_score: other_run, position: 2)
  end

  it 'shows the overview' do
    get "/contributions/group_scores/#{group_score.id}/participations/edit"
    expect(response.body).to include('Klicke auf eine Position',
                                     "/contributions/group_scores/#{group_score.id}/positions/7")
  end

  it 'suggests people of the team at this position' do
    get "#{path}/edit"
    expect(response.body).to include('Bekannt', 'Aktuell:')
  end

  it 'searches people' do
    create(:person, first_name: 'Erna', last_name: 'Gesucht', gender: :female)
    get "#{path}/edit", params: { q: 'Gesucht' }
    expect(response.body).not_to include('Gesucht</td>')

    get "#{path}/edit", params: { q: 'Gesucht', include_women: '1' }
    expect(response.body).to include('Gesucht')
  end

  it 'assigns and removes a person with change log' do
    patch path, params: { person_id: known.id }
    expect(response).to redirect_to("/contributions/group_scores/#{group_score.id}/participations/edit?changed=1")
    expect(group_score.person_participations.pluck(:position, :person_id)).to eq [[2, known.id]]
    expect(ChangeLog.last).to have_attributes(action: 'update-groupscore:participation', api_user: login_user)

    expect { patch path, params: { person_id: '' } }.to change(PersonParticipation, :count).by(-1)
  end

  it 'does not log without change' do
    expect { patch path, params: { person_id: '' } }.not_to change(ChangeLog, :count)
  end

  it 'rejects positions outside the discipline' do
    get "/contributions/group_scores/#{group_score.id}/positions/8/edit"
    expect(response).to have_http_status(:not_found)
  end

  it 'creates a new person for the position' do
    get '/contributions/people/new', params: { group_score_id: group_score.id, position: 2 }
    expect(response.body).to include('name="position"', 'Zurück')

    expect do
      post '/contributions/people', params: {
        group_score_id: group_score.id, position: 2,
        person: { first_name: 'Neu', last_name: 'Läufer', gender: 'male', nation_id: nation.id }
      }
    end.to change(Person, :count).by(1)
    expect(response).to redirect_to("/contributions/group_scores/#{group_score.id}/participations/edit?changed=1")
    expect(group_score.person_participations.first.person.last_name).to eq 'Läufer'
  end
end
