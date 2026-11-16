# frozen_string_literal: true

require 'rails_helper'

describe 'competitions features' do
  let(:competition) do
    create(:competition, :score_type)
    group_score = create(:group_score, :double)
    create(:score, :hb, :double, competition: group_score.competition)
    create(:score, :hl, :double, competition: group_score.competition).competition
  end

  context 'when show' do
    it 'shows the competition' do
      visit competition_path(competition)

      expect(page).to have_text('100m-Hindernisbahn (Männer)')
      expect(page).to have_text('1 bis 1 von 1 Einträgen')
      expect(page).to have_text('100m-Hindernisbahn (Männer) männlich Mannschaftswertung')

      expect(page).to have_text('Hakenleitersteigen (3. Etage) männlich')
      expect(page).to have_text('Hakenleitersteigen (3. Etage) männlich Mannschaftswertung')

      expect(page).to have_text('Zweikampf männlich')

      expect(page).to have_no_text('Löschangriff nass weiblich')
      expect(page).to have_text('Löschangriff nass männlich')
      expect(page).to have_text('Standardwertung WKO')

      within('.missed-3') do
        expect(page).to have_text('Folgende Informationen fehlen:')
      end
    end

    it 'shows the competition als xlsx' do
      visit competition_path(id: competition.id, format: :xlsx)
      expect(page.response_headers['content-type']).to eq(
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet; charset=utf-8',
      )
    end

    it 'adds change requests' do
      api_sign_in

      visit competition_path(competition)
      find_by_id('add-change-request').click

      within('dialog.contribution-dialog') do
        click_on 'Name des Wettkampfs vorschlagen'
        fill_in 'Name', with: 'Superduperwettkampf'
        click_on 'Vorschlagen'
        expect(page).to have_text('Der Fehlerbericht wurde gespeichert')
        click_on 'Schließen'
      end
      expect(page).to have_no_css('dialog[open]')

      change_request_content = ChangeRequest.last.content
      expect(change_request_content).to include key: 'competition-change-name'
      expect(change_request_content[:data]).to eq(competition_id: competition.id.to_s, name: 'Superduperwettkampf')

      find_by_id('add-change-request').click
      within('dialog.contribution-dialog') do
        click_on 'Hinweis geben'
        fill_in 'Beschreibe deinen Hinweis bitte ausführlich:', with: 'Wetterbericht'
        click_on 'Hinweis senden'
        expect(page).to have_text('Der Fehlerbericht wurde gespeichert')
      end

      change_request_content = ChangeRequest.last.content
      expect(change_request_content).to include key: 'competition-add-hint'
      expect(change_request_content[:data]).to eq(competition_id: competition.id.to_s, hint: 'Wetterbericht')
    end
  end

  context 'when file upload' do
    it 'uploads files and reports a file error' do
      api_sign_in

      visit competition_path(competition)
      click_on 'Datei hinzufügen'

      within('dialog.contribution-dialog') do
        expect(page).to have_text('Es dürfen nur PDF-Dateien hochgeladen werden.')
        attach_file('competition_file_0_file', File.expand_path(file_fixture('testfile.pdf')))
        check('competition_file_0_fs_female')
        click_on 'Noch eine Datei auswählen'
        attach_file('competition_file_1_file', File.expand_path(file_fixture('testfile.pdf')))
        check('competition_file_1_hb_male')
        click_on 'Hochladen'
      end
      expect(page).to have_no_css('dialog[open]')
      expect(page).to have_text('testfile.pdf')
      expect(CompetitionFile.order(:id).map(&:keys)).to eq [%w[fs_female], %w[hb_male]]

      first(:link, 'Fehler melden').click
      within('dialog.contribution-dialog') do
        expect(page).to have_text('testfile.pdf')
        fill_in 'Was ist an der Datei falsch?', with: 'Seite 2 fehlt'
        click_on 'Fehler melden'
        expect(page).to have_text('Der Fehlerbericht wurde gespeichert')
      end
      expect(ChangeRequest.last.content).to eq(
        key: 'competition-file-error',
        data: { competition_id: competition.id.to_s, fileId: CompetitionFile.order(:id).first.id.to_s,
                description: 'Seite 2 fehlt' },
      )
    end
  end
end
