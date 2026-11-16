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

    it 'can put people merge' do
      api_sign_in

      # add one
      visit person_path(person)
      find_by_id('add-change-request').click
      within('.fss-window') do
        expect(page).to have_text('Auswahl des Fehlers')
        choose('Person ist falsch geschrieben')
        click_on('OK')

        expect(page).to have_text('Korrektur des Fehlers')
        choose('Richtige Schreibweise auswählen (für Administrator VIEL einfacher)')
        click_on('OK')

        expect(page).to have_text('Namen korrigieren')
        select('Meier, Alfredo (männlich)', from: 'Richtige Person')
        click_on('OK')
      end
      expect(page).to have_text('Der Fehlerbericht wurde gespeichert')

      change_request_content = ChangeRequest.last.content
      expect(change_request_content).to eq(
        key: 'person-merge',
        data: { person_id: person.id.to_s, correct_person_id: alfredo.id.to_s },
      )
    end

    it 'can correct person' do
      api_sign_in

      # add one
      visit person_path(person)
      find_by_id('add-change-request').click
      within('.fss-window') do
        expect(page).to have_text('Auswahl des Fehlers')
        choose('Person ist falsch geschrieben')
        click_on('OK')

        expect(page).to have_text('Korrektur des Fehlers')
        choose('Selbst korrekte Schreibweise hinzufügen')
        click_on('OK')

        expect(page).to have_text('Namen korrigieren')
        fill_in 'Vorname', with: 'Vorname'
        fill_in 'Nachname', with: '00AABBCC'
        click_on('OK')
      end
      expect(page).to have_text('Der Fehlerbericht wurde gespeichert')

      change_request_content = ChangeRequest.last.content
      expect(change_request_content).to eq(
        key: 'person-correction',
        data: {
          person_id: person.id.to_s,
          person: { first_name: 'Vorname', last_name: '00AABBCC' },
        },
      )
    end

    it 'can correct nation' do
      api_sign_in

      # add one
      visit person_path(person)
      find_by_id('add-change-request').click
      within('.fss-window') do
        expect(page).to have_text('Auswahl des Fehlers')
        choose('Person ist falscher Nation zugeordnet')
        click_on('OK')

        expect(page).to have_text('Andere Nation')
        select('Ungarn', from: 'Nation')
        click_on('OK')
      end
      expect(page).to have_text('Der Fehlerbericht wurde gespeichert')

      change_request_content = ChangeRequest.last.content
      expect(change_request_content).to eq(
        key: 'person-change-nation',
        data: { person_id: person.id.to_s, nation_id: ungarn.id.to_s },
      )
    end

    it 'can add description' do
      api_sign_in

      # add one
      visit person_path(person)
      find_by_id('add-change-request').click
      within('.fss-window') do
        expect(page).to have_text('Auswahl des Fehlers')
        choose('Etwas anderes')
        click_on('OK')

        expect(page).to have_text('Fehler beschreiben')
        fill_in('Beschreibung', with: "Beschreibung\n123")
        click_on('OK')
      end
      expect(page).to have_text('Der Fehlerbericht wurde gespeichert')

      change_request_content = ChangeRequest.last.content
      expect(change_request_content).to eq(
        key: 'person-other',
        data: { person_id: person.id.to_s, description: "Beschreibung\r\n123" },
      )
    end
  end
end
