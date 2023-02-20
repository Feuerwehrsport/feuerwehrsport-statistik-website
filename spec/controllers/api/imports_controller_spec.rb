# frozen_string_literal: true

require 'rails_helper'

RSpec.describe API::ImportsController do
  describe 'POST check_lines' do
    let(:r) { -> { post :check_lines, params: { import: import } } }

    let!(:warin) { create(:team) }
    let(:raw_lines) { "Warin;foo;22\nFF Wurststadt;bla;44\nFC Hansa Rostock;blub;D" }
    let(:import) do
      { discipline: 'la', gender: 'male', separator: ';', raw_headline_columns: 'team;col;time', raw_lines: raw_lines }
    end

    it 'returns group_score', login: :sub_admin do
      r.call
      expect_api_login_response(
        missing_teams: ['FF Wurststadt', 'FC Hansa Rostock'],
        import_lines: [
          {
            valid: true,
            last_name: '',
            first_name: '',
            times: [2200],
            team_names: ['Warin'],
            original_team: 'Warin',
            run: 'A',
            team_number: 1,
            team_ids: [warin.id],
            people: [],
          }, {
            valid: true,
            last_name: '',
            first_name: '',
            times: [4400],
            team_names: [],
            original_team: 'FF Wurststadt',
            run: 'A',
            team_number: 1,
            correct: false,
            people: [],
          }, {
            valid: true,
            last_name: '',
            first_name: '',
            times: [99_999_999],
            team_names: [],
            original_team: 'FC Hansa Rostock',
            run: 'A',
            team_number: 1,
            correct: false,
            people: [],
          }
        ],
      )
    end

    it_behaves_like 'api user get permission error'

    context 'when params are not valid', login: :sub_admin do
      let(:import) { { discipline: 'foo', gender: 'male', raw_headline_columns: 'team', raw_lines: 'Warin' } }

      it 'returns failed' do
        r.call
        expect_json_response
        expect(json_body).to include(
          success: false,
          login: true,
        )
      end
    end
  end

  describe 'POST scores' do
    let(:r) { -> { post :scores, params: params } }
    let(:params) { { import: { discipline: discipline, gender: 'male', scores: scores }.merge(attributes) } }

    let(:competition) { create(:competition) }
    let(:team) { create(:team) }
    let(:group_score_category) { create(:group_score_category, competition: competition) }
    let!(:person) { create(:person) }
    let(:discipline) { 'hb' }
    let(:attributes) { { competition_id: competition.id } }
    let(:scores) { [person_id: person.id, times: ['2200']] }

    it_behaves_like 'api user get permission error'

    context 'when as valid user', login: :sub_admin do
      context 'when person exists' do
        it { expect { r.call }.to change(Score, :count).by(1) }
        it { expect { r.call }.not_to change(Person, :count) }
      end

      context 'when person does not exists' do
        let(:scores) { [first_name: 'Hans', last_name: 'Wurst', times: %w[2200 2300]] }

        it { expect { r.call }.to change(Score, :count).by(2) }
        it { expect { r.call }.to change(Person, :count).by(1) }
      end

      context 'when discipline is a group discipline' do
        let(:discipline) { 'la' }

        context 'when group_score_category_id is not set' do
          let(:scores) { [team_id: team.id, team_number: 1, times: ['2200']] }

          it { expect { r.call }.not_to change(GroupScore, :count) }
        end

        context 'when attributes are valid' do
          let(:attributes) { { group_score_category_id: group_score_category.id } }
          let(:scores) { [team_id: team.id, team_number: 1, times: ['2200']] }

          it do
            expect { r.call }.to change(GroupScore, :count).by(1)
            expect_change_log(klass: Import::Scores, after: { gender: 'male' }, log: 'scores-import-scores')
          end
        end
      end
    end
  end
end
