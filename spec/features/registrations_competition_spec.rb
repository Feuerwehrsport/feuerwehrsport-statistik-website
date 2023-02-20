# frozen_string_literal: true

require 'rails_helper'

describe 'registration feature', js: true do
  it 'creates competition' do
    sign_in :user

    click_on 'Wettkampfanmeldungen'
    click_on 'Neu erstellen'
    expect(page).to have_content('Vorlage für Wettkämpf wählen')

    within('.template:nth-child(5)') do
      save_review_screenshot
      click_on 'Als Vorlage wählen'
    end

    expect(find_field('registrations_competition_name').value).to eq 'Deutschland-Cup'
    save_review_screenshot
    fill_in 'Datum', with: Date.parse('2020-02-29')
    fill_in 'Ort', with: 'Ostseebad Nienhagen'
    click_on 'Wettkampf anlegen'

    expect(page).to have_content('URL zu dieser Seite')
    expect(page).not_to have_content('Wettkampf ist noch nicht öffentlich')
    expect(page).to have_content('29.02.2020')

    click_on 'Öffentlichkeitseinstellungen'
    within('.modal-content') do
      uncheck 'Veröffentlichen'
      save_review_screenshot
      click_on 'Speichern'
    end

    expect(page).to have_content('Wettkampf ist noch nicht öffentlich')
    expect(page).to have_content('Wettkampf bearbeiten')

    within('.panel', text: 'Zeiten für die Anmeldung') do
      click_on 'Bearbeiten'
    end
    within('.modal-content') do
      fill_in 'Anmeldung öffnen', with: '01.01.2019'
      fill_in 'Anmeldung schließen', with: '10.01.2019'
      save_review_screenshot
      click_on 'Speichern'
    end

    within('.panel', text: 'Wertungen') do
      click_on 'Bearbeiten'
    end
    expect(page).to have_content('Noch keine Anmeldungen für diese Wertung')
    save_review_screenshot
    click_on 'Neu erstellen'
    choose 'Hakenleitersteigen'
    choose 'weiblich'
    fill_in 'Name', with: 'Ü80'
    save_review_screenshot
    click_on 'Speichern'

    expect(page).to have_content('Ü80 - Hakenleitersteigen weiblich')
    save_review_screenshot
    within('.panel', text: 'Ü80 - Hakenleitersteigen weiblich') do
      click_on 'Bearbeiten'
    end
    fill_in 'Name', with: 'Ü90'
    click_on 'Speichern'

    expect(page).to have_content('Ü90 - Hakenleitersteigen weiblich')
    within('.panel', text: 'Ü90 - Hakenleitersteigen weiblich') do
      accept_confirm { click_on 'Löschen' }
    end
    expect(page).not_to have_content('Ü90 - Hakenleitersteigen weiblich')
    click_on 'Zurück zum Wettkampf'

    click_on 'Markierungen bearbeiten'
    within('.modal-content') do
      fill_in 'Anklickbare Werte für Mannschaften', with: 'Kreiswertung'
      check 'Mannschaftswertung für Einzeldisziplinen'
      save_review_screenshot
      click_on 'Speichern'
    end
    within('.panel-heading', text: 'Markierungen') do
      expect(page).to have_content('Markierungen')
      save_review_screenshot
    end

    click_on 'E-Mail versenden'
    fill_in 'Betreff', with: 'Neue Infos'
    fill_in 'Inhalt', with: 'Text'
    check 'Teilnehmerliste A und B automatisch als Anhang hinzufügen'
    save_review_screenshot
    click_on 'E-Mail senden'
    expect(page).to have_content('E-Mail wird im Hintergrund versendet')
  end
end
