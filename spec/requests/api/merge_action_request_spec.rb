# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'MergeAction (Api::People/Api::Teams merge)', login: :sub_admin do
  let!(:person) { create(:person) }
  let!(:correct_person) { create(:person, first_name: 'Alfredo', last_name: 'Mayer') }
  let!(:score) { create(:score, person:) }

  def merge(params = {})
    post "/api/people/#{person.id}/merge", params: { correct_person_id: correct_person.id }.merge(params)
  end

  it 'moves scores, removes source and creates no spelling without always' do
    expect { merge }.to change(Person, :count).by(-1).and change(EntityMerge, :count).by(1)
    expect(PersonSpelling.count).to eq 0
    expect_json_response
    expect(json_body).to include(success: true, resource_name: 'person')
    expect(score.reload.person_id).to eq correct_person.id
    expect(EntityMerge.last).to have_attributes(source_type: 'Person', source_id: person.id,
                                                target_type: 'Person', target_id: correct_person.id)
  end

  it 'creates spelling with always' do
    expect { merge(always: '1') }.to change(PersonSpelling, :count).by(1)
    expect(PersonSpelling.last).to have_attributes(person_id: correct_person.id, first_name: 'Alfred',
                                                   last_name: 'Meier')
  end

  it 'rolls back when source can not be destroyed' do
    allow_any_instance_of(Person).to receive(:destroy).and_return(false)
    merge
    expect(Person.count).to eq 2
    expect(EntityMerge.count).to eq 0
    expect_json_response
    expect(json_body).to include(success: false, message: "Could not destroy person with id ##{person.id}")
    expect(score.reload.person_id).to eq person.id
  end

  it 'returns not found for unknown correct person' do
    post "/api/people/#{person.id}/merge", params: { correct_person_id: 999_999 }
    expect(response).to have_http_status(:not_found)
  end

  describe 'teams' do
    let!(:team) { create(:team) }
    let!(:bad_team) { create(:team, :mv) }

    it 'merges teams' do
      expect do
        post "/api/teams/#{bad_team.id}/merge", params: { correct_team_id: team.id }
      end.to change(Team, :count).by(-1).and change(EntityMerge, :count).by(1)
      expect(json_body).to include(success: true, resource_name: 'team')
      expect(json_body[:team]).to include(id: team.id)
    end
  end
end
