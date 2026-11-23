# frozen_string_literal: true

require 'rails_helper'

describe 'backend unchecked places' do
  # answers the nominatim requests of the lookup controller with fixed data
  def stub_nominatim
    browser = page.driver.browser
    browser.network.intercept
    browser.on(:request) do |request|
      if request.url.include?('nominatim.openstreetmap.org')
        body = [{ display_name: 'Neuendorf, Sachsen', lat: '51.1', lon: '13.7', address: { country_code: 'de' } },
                { display_name: 'Neuendorf, Mecklenburg', lat: '53.8', lon: '11.7', address: { country_code: 'de' } }]
        request.respond(body: body.to_json,
                        responseHeaders: { 'Access-Control-Allow-Origin' => '*', 'Content-Type' => 'application/json' })
      elsif request.url.include?('openstreetmap')
        request.abort
      else
        request.continue
      end
    end
  end

  it 'highlights the place nearest to the teams and saves its position' do
    place = create(:place, name: 'Neuendorf')
    create(:score, team: create(:team, latitude: 53.9, longitude: 11.8), competition: create(:competition, place:))
    sign_in(:sub_admin)
    stub_nominatim

    visit backend_unchecked_place_path(place)
    expect(page).to have_css('tr.table-success', text: 'ca. 13 km von den Mannschaften')
    rows = all('tr', text: 'km von den Mannschaften').map { |row| row.text.squish }
    expect(rows.first).to start_with('Neuendorf, Mecklenburg')

    within('tr.table-success') { click_on 'Auswählen' }
    within('.team-map-actions') { click_on 'Speichern' }
    within('dialog.contribution-dialog') do
      uncheck 'Ort geprüft (aus der Liste nehmen)'
      click_on 'Position speichern'
    end
    expect(page).to have_no_css('dialog[open]')
    expect(place.reload).to have_attributes(latlon: [53.8, 11.7], checked_at: nil)
  end
end
