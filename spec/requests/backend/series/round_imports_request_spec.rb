# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Backend::Series::RoundImports', login: :admin do
  let(:round) { create(:series_round) }
  let(:competition) { create(:competition) }
  let(:person) { create(:person, :female, first_name: 'Anna', last_name: 'Ahrens') }
  let(:import_request) do
    create(:import_request, import_data: {
             results: [
               {
                 discipline: 'hb',
                 series_person_round_keys: ["#{round.id}-female"],
                 series_team_round_keys: [],
                 rows: [
                   %w[Platz Vorname Nachname statistik_person_id Bestzeit],
                   ['1.', 'Anna', 'Ahrens', person.id.to_s, '17,50'],
                   ['2.', 'Neue', 'Person', '', '18,50'],
                 ],
               },
             ],
           })
  end
  let(:params) do
    {
      series_round_import: {
        competition_id: competition.id,
        import_request_id: import_request.id,
        import_now:,
      },
    }
  end

  describe 'GET new' do
    it 'shows form' do
      get "/backend/series/rounds/#{round.id}/import/new"
      expect(response).to be_successful
    end
  end

  describe 'POST create' do
    context 'without import_now' do
      let(:import_now) { '0' }

      it 'shows preview and does not change anything' do
        expect do
          post "/backend/series/rounds/#{round.id}/import", params:
        end.not_to change(Series::PersonParticipation, :count)
        expect(Series::Cup.count).to eq 0

        expect(response).to be_successful
        expect(response.body).to include('Vorschau der Änderungen')
        expect(response.body).to include('Zuordnung von Wettkämpfern')
        expect(response.body).to include('series_round_import[person_assignments][neue__person]')
      end
    end

    context 'with import_now' do
      let(:import_now) { '1' }
      let(:other_person) { create(:person, first_name: 'Other', last_name: 'Person') }

      it 'imports data with given assignments' do
        params[:series_round_import][:person_assignments] = { 'neue__person' => other_person.id.to_s }
        expect do
          post "/backend/series/rounds/#{round.id}/import", params:
        end.to change(Series::PersonParticipation, :count).by(2).and change(Series::Cup, :count).by(1)

        expect(response).to redirect_to("/backend/series/rounds/#{round.id}")
        expect(Series::PersonParticipation.find_by(rank: 2).person).to eq other_person
        expect(Series::Cup.last.competition).to eq competition
      end
    end

    context 'without competition' do
      let(:import_now) { '1' }

      it 'does not report success' do
        params[:series_round_import].delete(:competition_id)
        expect do
          post "/backend/series/rounds/#{round.id}/import", params:
        end.not_to change(Series::Cup, :count)

        expect(response).not_to be_redirect
      end
    end
  end
end
