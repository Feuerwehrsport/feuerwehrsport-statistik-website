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
    expect(page).to have_link('Wettkampf', href: /new/)
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
end
