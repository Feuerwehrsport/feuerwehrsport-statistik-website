# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Backend::Imports', login: :admin do
  let!(:competition) { create(:competition) }
  let!(:team) { create(:team) }

  describe 'GET index' do
    it 'asks for a competition first' do
      get '/backend/imports'
      expect(response).to be_successful
      expect(response.body).to include('1. Wettkampf zuordnen')
      expect(response.body).not_to include('import-step-results')
    end

    it 'remembers the selected competition' do
      get '/backend/imports', params: { competition_id: competition.id }
      expect(response.body).to include('add-discipline discipline-la-male', 'Mannschaftswertung')

      get '/backend/imports'
      expect(response.body).to include("/backend/imports/disciplines/new?competition_id=#{competition.id}")
    end
  end

  describe 'competitions' do
    let!(:place) { create(:place, name: 'Waldheim') }
    let!(:event) { create(:event, name: 'Pokallauf') }
    let!(:amt) { create(:event, name: 'Amtsausscheid') }
    let!(:kreis) { create(:event, name: 'Kreisausscheid') }
    let(:competition_params) { { name: 'Finale', date: '2026-09-12', place_id: '', event_id: event.id } }

    it 'prefills the form with existing place and event' do
      get '/backend/imports/competitions/new', params: { name: 'Finale', date: '2026-09-12', place: 'waldheim',
                                                         return_to: '/backend/import_requests/1' }
      expect(response.body).to include('id="import-competition"', 'value="Finale"',
                                       %(selected="selected" value="#{place.id}">Waldheim),
                                       %(selected="selected" value="#{event.id}">Pokallauf))
      expect(response.body).not_to include('name="new_place_name" id="new_place_name" value="waldheim"')
    end

    it 'preselects the event by the name' do
      { 'Amtsausscheid Amt Bützow Land' => amt, '5. Kreisausscheid' => kreis, 'Pokallauf Samtens' => event,
        'Hallenpokal' => event }.each do |name, expected|
        get '/backend/imports/competitions/new', params: { name: }
        expect(response.body).to include(%(selected="selected" value="#{expected.id}">)), name
      end
    end

    it 'creates the competition with a new place and selects it' do
      expect do
        post '/backend/imports/competitions', params: { competition: competition_params, new_place_name: 'Neuort',
                                                        return_to: 'https://example.com/backend/import_requests/1' }
      end.to change(Competition, :count).by(1).and change(Place, :count).by(1).and not_change(Event, :count)
      new_competition = Competition.reorder(:id).last
      expect(new_competition).to have_attributes(name: 'Finale', place: Place.find_by(name: 'Neuort'), event:)
      expect(ChangeLog.pluck(:action)).to contain_exactly('create-place', 'create-competition')
      expect(response.body).to include('data-visit-url-value="/backend/import_requests/1"')

      get '/backend/imports'
      expect(response.body).to include("/backend/imports/disciplines/new?competition_id=#{new_competition.id}")
    end

    it 'uses an existing place with the new name' do
      expect do
        post '/backend/imports/competitions', params: { competition: competition_params,
                                                        new_place_name: 'WALDHEIM' }
      end.to change(Competition, :count).by(1).and not_change(Place, :count)
      expect(Competition.reorder(:id).last.place).to eq place
      expect(response.body).to include('data-visit-url-value="/backend/imports"')
    end

    it 'keeps nothing on errors' do
      expect do
        post '/backend/imports/competitions', params: { competition: competition_params.merge(date: ''),
                                                        new_place_name: 'Neuort' }
      end.not_to change(Place, :count)
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('value="Neuort"')
    end
  end

  describe 'PATCH score_type' do
    it 'sets the score type with change log' do
      score_type = create(:score_type)
      patch '/backend/imports/score_type', params: { competition_id: competition.id, score_type_id: score_type.id }
      expect(competition.reload.score_type).to eq score_type
      expect(ChangeLog.last).to have_attributes(action: 'update-competition:score-type')
    end
  end

  describe 'disciplines' do
    let(:input) { { competition_id: competition.id, separator: 'TAB' } }

    it 'shows the input with default columns' do
      get '/backend/imports/disciplines/new',
          params: { competition_id: competition.id, discipline: 'hb', gender: 'male' }
      expect(response.body).to include('id="import-discipline"', 'Testen')
      expect(response.body.scan('<option selected="selected" value="time">').size).to eq 3 # 2 + template
    end

    it 'shows errors of the input' do
      post '/backend/imports/disciplines/check', params: input.merge(discipline: 'hb', gender: 'male',
                                                                     columns: %w[time], raw_lines: '19,22')
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('has not all required columns')
    end

    context 'with single scores' do
      let!(:single_discipline) { create(:single_discipline, :hb_male) }
      let!(:person) { create(:person) }
      let(:params) do
        input.merge(discipline: 'hb', gender: 'male', columns: %w[last_name first_name team time time],
                    raw_lines: "Meier\tAlfred\tFF Warin\t19,22\t18,99\nNeu\tPeter\tFF Unbekannt\t20,00\tD")
      end

      it 'previews the lines with missing teams' do
        post('/backend/imports/disciplines/check', params:)
        expect(response.body).to include('Fehlende Mannschaften', 'FF Unbekannt anlegen', 'person-not-found',
                                         %(name="lines[0][person_id]" id="lines_0_person_id" value="#{person.id}"))
      end

      it 'creates a missing team and checks again' do
        expect do
          post '/backend/imports/disciplines/team',
               params: params.merge(team: { name: 'FF Unbekannt', shortcut: 'Unbekannt', status: 'fire_station' })
        end.to change(Team, :count).by(1)
        expect(response.body).not_to include('Fehlende Mannschaften')
      end

      it 'imports the selected lines' do
        post('/backend/imports/disciplines/check', params:)
        lines = {
          '0' => { valid: '1', person_id: person.id, team_id: team.id, team_number: 1, times: %w[1922 1899] },
          '1' => { valid: '0', last_name: 'Neu', first_name: 'Peter', team_number: 1, times: %w[2000] },
        }
        expect do
          post '/backend/imports/disciplines', params: params.merge(lines:, single_discipline_id: single_discipline.id)
        end.to change(Score, :count).by(2)
        expect(response.body).to include('2 Zeiten wurden eingetragen.')
        expect(Score.pluck(:person_id, :team_id, :time)).to contain_exactly([person.id, team.id, 1922],
                                                                            [person.id, team.id, 1899])
        expect(ChangeLog.last).to have_attributes(action: 'scores-import-scores')
      end

      it 'deselects lines with unknown teams and marks existing times' do
        create(:score, competition:, person:, single_discipline:, time: 1922)
        post('/backend/imports/disciplines/check', params:)
        expect(response.body).to match(/<input[^>]*name="lines\[0\]\[valid\]"[^>]*checked="checked"/)
        expect(response.body).not_to match(/<input[^>]*name="lines\[1\]\[valid\]"[^>]*checked="checked"/)
        expect(response.body).to include('duplicate-time', 'Doppelte Zeiten trotzdem eintragen')
      end

      it 'imports existing times only with confirmation' do
        create(:score, competition:, person:, single_discipline:, time: 1922)
        lines = { '0' => { valid: '1', person_id: person.id, team_id: team.id, team_number: 1, times: %w[1922] } }
        input = params.merge(lines:, single_discipline_id: single_discipline.id)
        expect { post '/backend/imports/disciplines', params: input }.not_to change(Score, :count)
        expect(response.body).to include('Einige Zeiten sind in diesem Wettkampf schon vorhanden.')

        expect do
          post '/backend/imports/disciplines', params: input.merge(confirm_duplicates: '1')
        end.to change(Score, :count).by(1)
      end

      it 'needs selected lines' do
        post '/backend/imports/disciplines', params: params.merge(lines: { '0' => { valid: '0', times: %w[1922] } })
        expect(response.body).to include('Keine gültigen Zeilen ausgewählt.')
      end
    end

    context 'with group scores' do
      let!(:group_score_type) { create(:group_score_type) }
      let(:params) do
        input.merge(discipline: 'la', gender: 'female', columns: %w[team time time],
                    raw_lines: "FF Warin\t22,87\t24,00")
      end

      it 'preselects new category without categories, one existing category, none with more' do
        post('/backend/imports/disciplines/check', params:)
        expect(response.body).to include('value="new" class="form-check-input" checked="checked"', 'value="default"')

        category = create(:group_score_category, competition:, group_score_type:)
        post('/backend/imports/disciplines/check', params:)
        expect(response.body).to include(%(value="#{category.id}" class="form-check-input" checked="checked"))

        create(:group_score_category, competition:, group_score_type:, name: 'Zweite')
        post('/backend/imports/disciplines/check', params:)
        expect(response.body).not_to match(/name="group_score_category_id"[^>]*checked/)
      end

      it 'needs a category' do
        post '/backend/imports/disciplines', params: params.merge(
          lines: { '0' => { valid: '1', team_id: team.id, team_number: 1, times: %w[2287] } },
        )
        expect(response.body).to include('Bitte eine Kategorie wählen.')
      end

      it 'imports into a new category' do
        expect do
          post '/backend/imports/disciplines', params: params.merge(
            group_score_category_id: 'new', category_name: 'Neu', group_score_type_id: group_score_type.id,
            lines: { '0' => { valid: '1', team_id: team.id, team_number: 1, times: %w[2287 2400] } }
          )
        end.to change(GroupScore, :count).by(2).and change(GroupScoreCategory, :count).by(1)
        expect(GroupScoreCategory.last).to have_attributes(name: 'Neu', competition_id: competition.id)
      end
    end

    context 'with an import request' do
      let(:import_request) do
        create(:import_request).tap do |request|
          request.update_column(:import_data, { results: [{ discipline: 'hl', gender: 'female', name: 'HL',
                                                            rows: [%w[Nachname Vorname Mannschaft time foo],
                                                                   %w[Meier Anna Warin 17,5 x]] }] })
        end
      end

      it 'remembers the imported result' do
        create(:single_discipline, :hl_female)
        person = create(:person, :female)
        post '/backend/imports/disciplines', params: {
          competition_id: competition.id, discipline: 'hl', gender: 'female', separator: 'TAB', raw_lines: '',
          import_request_id: import_request.id, result_index: 0, single_discipline_id: SingleDiscipline.last.id,
          lines: { '0' => { valid: '1', person_id: person.id, team_number: 1, times: %w[1750] } }
        }
        expect(response.body).to include('1 Zeiten wurden eingetragen.')
        expect(import_request.reload.result_imported?(0, 'female')).to be true
        expect(import_request.result_imported?(0, 'male')).to be false
      end

      it 'fills the input with the rows of the result' do
        get '/backend/imports/disciplines/new', params: { competition_id: competition.id, discipline: 'hl',
                                                          gender: 'female', import_request_id: import_request.id,
                                                          result_index: 0 }
        expect(response.body).to include("Meier\tAnna\tWarin\t17,5\tx", '<option selected="selected" value="col">')
      end
    end
  end
end
