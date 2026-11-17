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

  context 'when editing teams of scores' do
    it 'assigns a team and team numbers' do
      score = create(:score, :hb, team: nil, team_number: 0)
      team = create(:team, name: 'FF Neustadt', shortcut: 'Neustadt')

      api_sign_in
      visit competition_path(score.competition)
      find('.btn', text: 'Mannschaften bearbeiten').click
      find('.change-team .time-col a', match: :first).click

      within('dialog.contribution-dialog') do
        fill_in 'Mannschaft suchen', with: 'Neustadt'
        click_on 'Suchen'
        choose 'FF Neustadt (Neustadt)'
        click_on 'Weiter'
        select 'Mannschaft 2', from: "#{score.decorate.translated_discipline_name}: #{score.decorate.second_time}"
        click_on 'Speichern'
      end
      expect(page).to have_no_css('dialog[open]')
      expect(score.reload).to have_attributes(team_id: team.id, team_number: 2)
      expect(ChangeLog.last).to have_attributes(action: 'update-score:team')
    end
  end

  context 'when editing positions of group scores' do
    it 'assigns, copies and creates people for positions' do
      first_run = create(:group_score, :double)
      second_run = GroupScore.where.not(id: first_run.id).first
      known = create(:person, first_name: 'Karl', last_name: 'Bekannt')
      # earlier start at position 2 for the same team at another competition -> suggestion
      other_category = create(:group_score_category, competition: create(:competition, name: 'Früher'))
      earlier_run = create(:group_score, team: first_run.team, group_score_category: other_category)
      create(:person_participation, person: known, group_score: earlier_run, position: 2)

      api_sign_in
      visit competition_path(first_run.competition)
      find('.btn', text: 'Positionen bearbeiten', match: :first).click
      find('.change-position .time-col a', match: :first).click

      within('dialog.contribution-dialog') do
        expect(page).to have_text('Klicke auf eine Position')
        # WK2 of the first run (rows are ordered by id)
        first('tbody tr').all('td')[1].click_on('+')
        expect(page).to have_text('Aktuell: niemand')
        within('tr', text: 'Bekannt') { click_on 'Auswählen' }

        expect(page).to have_text('Klicke auf eine Position')
        expect(page).to have_link('K. Bekannt')
        click_on '↧'
        expect(page).to have_link('K. Bekannt', count: 2)

        first('tbody tr').first('td').click_on('+')
        click_on 'Neue Person anlegen'
        fill_in 'Vorname', with: 'Neu'
        fill_in 'Nachname', with: 'Läufer'
        click_on 'Speichern'
        expect(page).to have_link('N. Läufer')
        click_on 'Fertig'
      end

      expect(page).to have_no_css('dialog[open]')
      expect(first_run.person_participations.order(:position).map { [it.position, it.person.last_name] })
        .to eq [[1, 'Läufer'], [2, 'Bekannt']]
      expect(second_run.person_participations.map { [it.position, it.person_id] }).to eq [[2, known.id]]
      expect(ChangeLog.where(action: 'update-groupscore:participation').count).to eq 3
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
