# frozen_string_literal: true

require 'rails_helper'

describe 'backend unchecked teams' do
  # answers the requests of the lookup controller in the browser with fixed data
  def stub_lookups
    browser = page.driver.browser
    browser.network.intercept
    browser.on(:request) do |request|
      if request.url.include?('nominatim.openstreetmap.org')
        request.respond(body: [{ display_name: 'Warin, Deutschland', lat: '53.8', lon: '11.7',
                                 address: { country_code: 'de', state: 'Sachsen' } }].to_json,
                        responseHeaders: { 'Access-Control-Allow-Origin' => '*', 'Content-Type' => 'application/json' })
      elsif request.url.include?('wikipedia.org')
        body = { query: { search: [{ pageid: 1, title: 'Warin',
                                     snippet: '<span>Stadt</span><img src=x onerror=alert(1)>' }] } }
        request.respond(body: body.to_json,
                        responseHeaders: { 'Access-Control-Allow-Origin' => '*', 'Content-Type' => 'application/json' })
      elsif request.url.include?('openstreetmap')
        request.abort
      else
        request.continue
      end
    end
  end

  it 'chooses a place found by name for the map and its state' do
    team = create(:team, :without_geo_location, checked_at: nil)
    sign_in(:sub_admin)
    stub_lookups

    visit backend_unchecked_team_path(team)
    expect(page).to have_link('Warin', href: 'https://de.wikipedia.org/?curid=1')
    expect(page).to have_text('Stadt')
    expect(page).to have_no_css('img[src=x]')

    within('tr', text: 'Warin, Deutschland') { click_on 'Auswählen' }
    within('.team-map-actions') { click_on 'Speichern' }
    within('dialog.contribution-dialog') do
      expect(page).to have_text('Breite 53.8, Länge 11.7')
      expect(page).to have_checked_field('Land/Bundesland auf „Sachsen“ setzen')
      click_on 'Position speichern'
    end
    expect(page).to have_no_css('dialog[open]')
    expect(team.reload).to have_attributes(latitude: 53.8, longitude: 11.7, state: 'SN')
  end
end
