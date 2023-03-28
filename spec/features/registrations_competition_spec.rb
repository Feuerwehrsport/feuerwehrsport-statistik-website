# frozen_string_literal: true

require 'rails_helper'

describe 'registration feature', js: true do
  it 'creates competition' do
    sign_in :user

    click_on 'Wettkampfanmeldungen'
    click_on 'Neu erstellen'
    expect(page).to have_content('Vorlage für Wettkämpf wählen')

    within('.panel', text: 'Deutschland-Cup') do
      click_on 'Auswählen'
    end

    expect(find_field('registrations_competition_name').value).to eq ''
    fill_in 'Name', with: 'Deutschland-Cup'
    fill_in 'Datum', with: Date.parse('2020-02-29')
    fill_in 'Ort', with: 'Ostseebad Nienhagen'
    click_on 'Wettkampf anlegen'

    expect(page).to have_content('URL zu dieser Seite')
    expect(page).not_to have_content('Wettkampf ist noch nicht öffentlich')
    expect(page).to have_content('29.02.2020')

    click_on 'Öffentlichkeitseinstellungen'
    within('.modal-content') do
      uncheck 'Veröffentlichen'
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
      click_on 'Speichern'
    end

    within('.panel', text: 'Wertungen') do
      click_on 'Bearbeiten'
    end
    expect(page).to have_content('Noch keine Anmeldungen für diese Wertung')
    click_on 'Wertung hinzufügen', match: :first
    within('.panel', text: 'Hakenleitersteigen') do
      click_on 'Auswählen'
    end

    fill_in 'Name', with: 'Ü80'
    click_on 'Speichern'

    expect(page).to have_content('Ü80 - Hakenleitersteigen')
    within('.panel', text: 'Ü80 - Hakenleitersteigen') do
      click_on 'Bearbeiten'
    end
    fill_in 'Name', with: 'Ü90'
    click_on 'Speichern'

    expect(page).to have_content('Ü90 - Hakenleitersteigen')
    within('.panel', text: 'Ü90 - Hakenleitersteigen') do
      accept_confirm { click_on 'Löschen' }
    end
    expect(page).not_to have_content('Ü90 - Hakenleitersteigen')
  end
end
