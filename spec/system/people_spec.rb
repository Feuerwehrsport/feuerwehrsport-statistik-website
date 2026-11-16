# frozen_string_literal: true

require 'rails_helper'

describe 'people' do
  let(:nation) { create(:nation) }
  let(:person) { create(:person) }

  context 'when index' do
    it 'can add person after anonymous login in the dialog' do
      nation
      visit people_path
      click_on 'Person hinzufügen'

      within('dialog.contribution-dialog') do
        expect(page).to have_text('Anmelden')
        answer_login_question
        fill_in 'Name', with: 'Tester'
        click_on 'Anmelden'

        expect(page).to have_text('Person hinzufügen')
        click_on 'Speichern'
        expect(page).to have_text('muss ausgefüllt werden')

        fill_in 'Vorname', with: 'Vorname'
        fill_in 'Nachname', with: '00AABBCC'
        select('weiblich', from: 'Geschlecht')
        select(nation.name, from: 'Nation')
        click_on 'Speichern'
      end

      expect(page).to have_no_css('dialog[open]')
      person = Person.find_by!(last_name: '00AABBCC')
      expect(person.attributes.symbolize_keys).to include(first_name: 'Vorname', gender: 'female',
                                                          nation_id: nation.id)
      expect(ChangeLog.last).to have_attributes(action: 'create-person', api_user: ApiUser.find_by!(name: 'Tester'))
    end

    it 'can cancel the dialog' do
      visit people_path
      click_on 'Person hinzufügen'
      within('dialog.contribution-dialog') { click_on 'Abbrechen' }
      expect(page).to have_no_css('dialog[open]')

      click_on 'Person hinzufügen'
      expect(page).to have_css('dialog[open]', text: 'Anmelden')
    end
  end

  context 'when add change request' do
    let!(:alfredo) { create(:person, first_name: 'Alfredo') }
    let!(:ungarn) { create(:nation, :ungarn) }

    def open_change_request_dialog
      api_sign_in
      visit person_path(person)
      click_on 'Fehler mit dieser Person melden'
      expect(page).to have_css('dialog[open]', text: 'Was ist falsch?')
      # the dialog itself is focused, not the first choice (would look selected)
      expect(page.evaluate_script('document.activeElement.tagName')).to eq 'DIALOG'
    end

    def expect_change_request(content)
      expect(page).to have_text('Der Fehlerbericht wurde gespeichert')
      expect(ChangeRequest.last.content).to eq(content)
      within('dialog.contribution-dialog') { click_on 'Schließen' }
      expect(page).to have_no_css('dialog[open]')
    end

    it 'can put people merge' do
      open_change_request_dialog
      within('dialog.contribution-dialog') do
        click_on 'Person ist falsch geschrieben'
        click_on 'Richtige Schreibweise auswählen'

        expect(page).to have_field('Name suchen')
        expect(page.evaluate_script('document.activeElement.id')).to eq 'q'
        fill_in 'Name suchen', with: 'Alfredo'
        click_on 'Suchen'
        expect(page).to have_no_text("#{person.last_name}, #{person.first_name} (")
        choose 'Meier, Alfredo (männlich)'
        click_on 'Fehler melden'
      end

      expect_change_request(key: 'person-merge',
                            data: { person_id: person.id.to_s, correct_person_id: alfredo.id.to_s })
    end

    it 'requires a selected person for merge' do
      open_change_request_dialog
      within('dialog.contribution-dialog') do
        click_on 'Person ist falsch geschrieben'
        click_on 'Richtige Schreibweise auswählen'
        fill_in 'Name suchen', with: 'Alfredo'
        click_on 'Suchen'
        click_on 'Fehler melden'
        expect(page).to have_text('Bitte die richtige Person auswählen.')
      end
      expect(ChangeRequest.count).to eq 0
    end

    it 'can correct person' do
      open_change_request_dialog
      within('dialog.contribution-dialog') do
        click_on 'Person ist falsch geschrieben'
        click_on 'Selbst korrekte Schreibweise angeben'

        expect(page).to have_field('Vorname', with: person.first_name)
        fill_in 'Vorname', with: 'Vorname'
        fill_in 'Nachname', with: '00AABBCC'
        click_on 'Fehler melden'
      end

      expect_change_request(key: 'person-correction',
                            data: { person_id: person.id.to_s,
                                    person: { first_name: 'Vorname', last_name: '00AABBCC' } })
    end

    it 'can correct nation' do
      open_change_request_dialog
      within('dialog.contribution-dialog') do
        click_on 'Person ist falscher Nation zugeordnet'
        select 'Ungarn', from: 'Nation'
        click_on 'Fehler melden'
      end

      expect_change_request(key: 'person-change-nation',
                            data: { person_id: person.id.to_s, nation_id: ungarn.id.to_s })
    end

    it 'can add description' do
      open_change_request_dialog
      within('dialog.contribution-dialog') do
        click_on 'Etwas anderes'
        fill_in 'Bitte beschreiben Sie das Problem:', with: "Beschreibung\n123"
        click_on 'Fehler melden'
      end

      expect_change_request(key: 'person-other',
                            data: { person_id: person.id.to_s, description: "Beschreibung\n123" })
    end
  end
end
