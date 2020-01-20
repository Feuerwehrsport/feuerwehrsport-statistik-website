require 'rails_helper'

describe 'people', type: :feature, js: true do
  let(:nation) { create(:nation) }
  let(:person) { create(:person) }

  context 'when index' do
    it 'can step pages' do
      create_list(:person, 13, :female)

      visit people_path
      expect(page).to have_content '1 bis 10 von 13 Einträgen'
      save_review_screenshot
      click_on 'Nächste', match: :first
      expect(page).to have_content '11 bis 13 von 13 Einträgen'
      click_on 'Zurück', match: :first
      expect(page).to have_content '1 bis 10 von 13 Einträgen'
    end

    it 'can add person' do
      nation

      api_sign_in

      # add one
      visit people_path
      sleep 0.1
      find('#add-person').click
      within('.fss-window') do
        expect(page).to have_content('Person hinzufügen')
        fill_in 'Vorname', with: 'Vorname'
        fill_in 'Nachname', with: '00AABBCC'
        select('weiblich', from: 'Geschlecht')
        select('Deutschland', from: 'Nation')
        click_on('OK')
      end

      Timeout.timeout(5) do
        loop do
          person = Person.where(last_name: '00AABBCC')
          break if person.present?
        end
      end
      person = Person.where(last_name: '00AABBCC')

      expect(person.count).to eq 1
      expect(person.first.attributes.symbolize_keys).to include(
        last_name: '00AABBCC',
        first_name: 'Vorname',
        gender: 'female',
        nation_id: nation.id,
      )
    end
  end

  context 'when add change request' do
    let!(:alfredo) { create(:person, first_name: 'Alfredo') }
    let!(:ungarn) { create(:nation, :ungarn) }

    it 'can put people merge' do
      api_sign_in

      # add one
      visit person_path(person)
      find('#add-change-request').click
      within('.fss-window') do
        expect(page).to have_content('Auswahl des Fehlers')
        choose('Person ist falsch geschrieben')
        click_on('OK')

        expect(page).to have_content('Korrektur des Fehlers')
        choose('Richtige Schreibweise auswählen (für Administrator VIEL einfacher)')
        click_on('OK')

        expect(page).to have_content('Namen korrigieren')
        save_review_screenshot
        select('Meier, Alfredo (männlich)', from: 'Richtige Person')
        click_on('OK')
      end
      expect(page).to have_content('Der Fehlerbericht wurde gespeichert')

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
      find('#add-change-request').click
      within('.fss-window') do
        expect(page).to have_content('Auswahl des Fehlers')
        choose('Person ist falsch geschrieben')
        click_on('OK')

        expect(page).to have_content('Korrektur des Fehlers')
        choose('Selbst korrekte Schreibweise hinzufügen')
        click_on('OK')

        expect(page).to have_content('Namen korrigieren')
        fill_in 'Vorname', with: 'Vorname'
        fill_in 'Nachname', with: '00AABBCC'
        click_on('OK')
      end
      expect(page).to have_content('Der Fehlerbericht wurde gespeichert')

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
      find('#add-change-request').click
      within('.fss-window') do
        expect(page).to have_content('Auswahl des Fehlers')
        choose('Person ist falscher Nation zugeordnet')
        click_on('OK')

        expect(page).to have_content('Andere Nation')
        select('Ungarn', from: 'Nation')
        click_on('OK')
      end
      expect(page).to have_content('Der Fehlerbericht wurde gespeichert')

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
      find('#add-change-request').click
      within('.fss-window') do
        expect(page).to have_content('Auswahl des Fehlers')
        choose('Etwas anderes')
        click_on('OK')

        expect(page).to have_content('Fehler beschreiben')
        fill_in('Beschreibung', with: "Beschreibung\n123")
        click_on('OK')
      end
      expect(page).to have_content('Der Fehlerbericht wurde gespeichert')

      change_request_content = ChangeRequest.last.content
      expect(change_request_content).to eq(
        key: 'person-other',
        data: { person_id: person.id.to_s, description: "Beschreibung\r\n123" },
      )
    end
  end
end
