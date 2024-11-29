# frozen_string_literal: true

require 'rails_helper'

describe 'competitions features', :js do
  let(:competition) do
    create(:competition, :score_type)
    group_score = create(:group_score, :double)
    create(:score, :hb, :double, competition: group_score.competition)
    create(:score, :hl, :double, competition: group_score.competition).competition
  end

  context 'when show' do
    it 'shows the competition' do
      visit competition_path(competition)

      expect(page).to have_content('100m-Hindernisbahn (Männer)')
      expect(page).to have_content('1 bis 1 von 1 Einträgen')
      expect(page).to have_content('100m-Hindernisbahn (Männer) männlich Mannschaftswertung')

      expect(page).to have_content('Hakenleitersteigen (3. Etage) männlich')
      expect(page).to have_content('Hakenleitersteigen (3. Etage) männlich Mannschaftswertung')

      expect(page).to have_content('Zweikampf männlich')

      expect(page).to have_no_content('Löschangriff nass weiblich')
      expect(page).to have_content('Löschangriff nass männlich')
      expect(page).to have_content('Standardwertung WKO')

      within('.missed-3') do
        expect(page).to have_content('Folgende Informationen fehlen:')
      end
    end

    it 'shows the competition als xlsx' do
      visit competition_path(id: competition.id, format: :xlsx)
      expect(page.response_headers['Content-Type']).to eq(
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet; charset=utf-8',
      )
    end

    it 'adds change requests', retry: 3 do
      api_sign_in

      visit competition_path(competition)
      find_by_id('add-change-request').click

      within('.fss-window') do
        expect(page).to have_content('Auswahl des Fehlers')
        choose('Name des Wettkampfs vorschlagen')
        click_on('OK')
      end

      within('.fss-window') do
        expect(page).to have_content('Namen vorschlagen')
        fill_in 'Name', with: 'Superduperwettkampf'
        click_on('OK')
      end
      expect(page).to have_content('Der Fehlerbericht wurde gespeichert')
      click_on('OK')

      change_request_content = ChangeRequest.last.content
      expect(change_request_content).to include key: 'competition-change-name'
      expect(change_request_content[:data]).to eq(competition_id: competition.id.to_s, name: 'Superduperwettkampf')

      find_by_id('add-change-request').click

      within('.fss-window') do
        expect(page).to have_content('Auswahl des Fehlers')
        choose('Hinweis geben')
        click_on('OK')
      end

      within('.fss-window') do
        expect(page).to have_content('Hinweis beschreiben')
        fill_in 'Beschreibung', with: 'Wetterbericht'
        click_on('OK')
      end
      expect(page).to have_content('Der Fehlerbericht wurde gespeichert')
      click_on('OK')

      change_request_content = ChangeRequest.last.content
      expect(change_request_content).to include key: 'competition-add-hint'
      expect(change_request_content[:data]).to eq(competition_id: competition.id.to_s, hint: 'Wetterbericht')
    end
  end

  context 'when file upload' do
    it 'adds change requests', retry: 3 do
      api_sign_in

      visit competition_path(competition)
      find_by_id('add-file').click

      expect(page).to have_content('Es dürfen nur PDFs hochgeladen werden.')
      attach_file('competition_file[0][file]', File.expand_path(file_fixture('testfile.pdf')))
      check('competition_file[0][fs_female]')
      click_on('Hochladen')
      expect(page).to have_content('testfile.pdf')
    end
  end
end
