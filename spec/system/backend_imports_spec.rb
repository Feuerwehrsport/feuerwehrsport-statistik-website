# frozen_string_literal: true

require 'rails_helper'

describe 'backend imports' do
  it 'imports single scores of a competition' do
    competition = create(:competition)
    create(:single_discipline, :hb_male)
    person = create(:person)

    sign_in(:admin)
    visit backend_imports_path
    select "#{competition.decorate.date} - #{competition.event.name} - #{competition.place.name}", from: 'Wettkampf'
    expect(page).to have_button('Anderen Wettkampf wählen')
    find('a.discipline-hb-male').click

    within('#import-discipline') do
      fill_in 'Ergebnisse (eine Zeile pro Ergebnis, Spalten wie oben)',
              with: "Meier\tAlfred\tFF Neustadt\t19,22\t18,99"
      click_on 'Testen'
      expect(page).to have_text('Fehlende Mannschaften')
      click_on 'FF Neustadt anlegen'
      expect(page).to have_no_text('Fehlende Mannschaften')
      click_on 'Eintragen'
    end
    expect(page).to have_css('#competition-scores', text: '2')
    expect(Score.where(person:).pluck(:time)).to contain_exactly(1922, 1899)
  end

  it 'creates and selects a competition with a new place' do
    create(:event, name: 'D-Cup')
    create(:event, name: 'Pokallauf')

    sign_in(:admin)
    visit backend_imports_path
    click_on 'Neuen Wettkampf anlegen'
    within('#import-competition') do
      fill_in 'Name', with: 'Finale'
      fill_in 'Datum', with: '2026-09-12'
      fill_in 'Neuer Ort', with: 'Neuort'
      expect(page).to have_select('Typ', selected: 'Pokallauf')
      select 'D-Cup', from: 'Typ'
      click_on 'Anlegen und auswählen'
    end
    expect(page).to have_css('#competition-link', text: 'Neuort')
    expect(page).to have_css('a.discipline-hb-male')
  end
end
