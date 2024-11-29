# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Suggestions' do
  describe 'POST people' do
    let!(:person1) { create(:person) }
    let!(:score1) { create(:score, person: person1) }
    let(:person1_hash) do
      {
        id: person1.id,
        last_name: 'Meier',
        first_name: 'Alfred',
        gender: 'male',
        gender_translated: 'männlich',
        teams: ['Warin'],
      }
    end

    let!(:person2) { create(:person, first_name: 'Alfredo') }
    let(:person2_hash) do
      {
        id: person2.id,
        last_name: 'Meier',
        first_name: 'Alfredo',
        gender: 'male',
        gender_translated: 'männlich',
        teams: [],
      }
    end

    let!(:person3) { create(:person, first_name: 'Alfredoro') }
    let!(:score3) { create(:score, person: person3) }
    let(:person3_hash) do
      {
        id: person3.id,
        last_name: 'Meier',
        first_name: 'Alfredoro',
        gender: 'male',
        gender_translated: 'männlich',
        teams: ['Warin'],
      }
    end

    let!(:person4) { create(:person, first_name: 'Doro', gender: :female) }
    let(:person4_hash) do
      {
        id: person4.id,
        last_name: 'Meier',
        first_name: 'Doro',
        gender: 'female',
        gender_translated: 'weiblich',
        teams: [],
      }
    end

    let(:attributes) { {} }
    let(:group_score) { create(:person_participation).group_score }

    context 'when attributes empty' do
      it 'returns people' do
        post '/api/suggestions/people', params: attributes
        expect_json_response
        expect(json_body[:people]).to contain_exactly(person1_hash, person2_hash, person3_hash, person4_hash)
      end
    end

    context 'when name given' do
      let(:attributes) { { name: 'oromeier' } }

      it 'returns people' do
        post '/api/suggestions/people', params: attributes
        expect_json_response
        expect(json_body[:people]).to eq [person3_hash, person4_hash]
      end

      context 'when order by gender' do
        let(:attributes) { { name: 'oromeier', gender: 'female' } }

        it 'returns people' do
          post '/api/suggestions/people', params: attributes
          expect_json_response
          expect(json_body[:people]).to eq [person4_hash, person3_hash]
        end
      end

      context 'when order by team name' do
        let(:attributes) { { name: 'alfmeier', team_name: 'warin' } }

        it 'returns people' do
          post '/api/suggestions/people', params: attributes
          expect_json_response
          expect(json_body[:people]).to eq [person1_hash, person3_hash, person2_hash]
        end
      end
    end

    context 'when gender given' do
      let(:attributes) { { real_gender: 'female' } }

      it 'returns people' do
        post '/api/suggestions/people', params: attributes
        expect_json_response
        expect(json_body[:people]).to eq [person4_hash]
      end
    end

    context 'when score given' do
      let(:attributes) { { score_id: group_score.id } }

      it 'returns people' do
        post '/api/suggestions/people', params: attributes
        expect_json_response
        expect(json_body[:people]).to eq [person1_hash, person3_hash]
      end
    end
  end

  describe 'POST teams' do
    let!(:team1) { create(:team) }
    let(:team1_hash) { { id: team1.id, name: 'FF Warin', shortcut: 'Warin' } }
    let!(:team2) { create(:team, :mv) }
    let(:team2_hash) { { id: team2.id, name: 'Team Mecklenburg-Vorpommern', shortcut: 'Team MV' } }

    let(:attributes) { {} }

    context 'when attributes empty' do
      it 'returns teams' do
        post '/api/suggestions/teams', params: attributes
        expect_json_response
        expect(json_body[:teams]).to eq [team1_hash, team2_hash]
      end
    end

    context 'when name given' do
      let(:attributes) { { name: 'arin' } }

      it 'returns people' do
        post '/api/suggestions/teams', params: attributes
        expect_json_response
        expect(json_body[:teams]).to eq [team1_hash]
      end
    end
  end
end
