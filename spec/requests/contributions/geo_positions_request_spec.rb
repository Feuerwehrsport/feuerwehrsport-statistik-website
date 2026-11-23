# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contributions::GeoPositions', login: :api do
  let!(:team) { create(:team) }
  let!(:place) { create(:place) }

  it 'asks to save the new position' do
    get "/contributions/teams/#{team.id}/geo_position/edit", params: { latitude: '53.1234567', longitude: '11.5' }
    expect(response.body).to include('Breite 53.123457, Länge 11.5', 'Position speichern')
  end

  it 'updates a team with change log' do
    patch "/contributions/teams/#{team.id}/geo_position", params: { latitude: '53.1', longitude: '11.5' }
    expect(team.reload).to have_attributes(latitude: 53.1, longitude: 11.5)
    expect(ChangeLog.last).to have_attributes(action: 'update-team:geo-position', api_user: login_user)
    expect(ChangeLog.last.content[:before_hash]).to be_present
  end

  it 'offers the state of the chosen place' do
    get "/contributions/teams/#{team.id}/geo_position/edit",
        params: { latitude: '51', longitude: '13', place_country: 'de', place_state: 'Sachsen' }
    expect(response.body).to include('name="state"', 'value="SN"', '„Sachsen“ setzen')
  end

  it 'does not offer the current state' do
    get "/contributions/teams/#{team.id}/geo_position/edit",
        params: { latitude: '51', longitude: '13', place_country: 'de', place_state: 'Mecklenburg-Vorpommern' }
    expect(response.body).not_to include('name="state"')
  end

  it 'updates position and state of a team' do
    patch "/contributions/teams/#{team.id}/geo_position", params: { latitude: '51', longitude: '13', state: 'SN' }
    expect(team.reload).to have_attributes(latitude: 51, longitude: 13, state: 'SN')
  end

  it 'ignores an unknown state' do
    patch "/contributions/teams/#{team.id}/geo_position", params: { latitude: '51', longitude: '13', state: 'XX' }
    expect(team.reload).to have_attributes(latitude: 51, state: 'MV')
  end

  it 'updates a place' do
    patch "/contributions/places/#{place.id}/geo_position", params: { latitude: '50', longitude: '10' }
    expect(place.reload).to have_attributes(latitude: 50, longitude: 10)
    expect(ChangeLog.last).to have_attributes(action: 'update-place:geo-position')
  end

  it 'rejects invalid coordinates' do
    patch "/contributions/places/#{place.id}/geo_position", params: { latitude: '91', longitude: 'abc' }
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include('Die Position ist ungültig.')
    expect(place.reload.latitude).to be_nil
  end

  describe 'marking as checked' do
    let!(:unchecked_team) { create(:team, checked_at: nil) }

    it 'is not offered to simple api users' do
      get "/contributions/teams/#{unchecked_team.id}/geo_position/edit",
          params: { latitude: '51', longitude: '13', offer_check: '1' }
      expect(response.body).not_to include('name="checked"')

      patch "/contributions/teams/#{unchecked_team.id}/geo_position",
            params: { latitude: '51', longitude: '13', offer_check: '1', checked: '1' }
      expect(unchecked_team.reload.checked_at).to be_nil
    end

    context 'with sub admin', login: :sub_admin do
      it 'offers the checkbox only for unchecked records from the list' do
        get "/contributions/teams/#{unchecked_team.id}/geo_position/edit",
            params: { latitude: '51', longitude: '13', offer_check: '1' }
        expect(response.body).to include('name="checked"', 'checked="checked"', 'Mannschaft geprüft')

        get "/contributions/teams/#{unchecked_team.id}/geo_position/edit", params: { latitude: '51', longitude: '13' }
        expect(response.body).not_to include('name="checked"')

        checked_team = create(:team, checked_at: Time.current)
        get "/contributions/teams/#{checked_team.id}/geo_position/edit",
            params: { latitude: '51', longitude: '13', offer_check: '1' }
        expect(response.body).not_to include('name="checked"')
      end

      it 'marks the place as checked and goes back to the list' do
        unchecked_place = create(:place, checked_at: nil)
        patch "/contributions/places/#{unchecked_place.id}/geo_position",
              params: { latitude: '50', longitude: '10', offer_check: '1', checked: '1' }
        expect(unchecked_place.reload).to have_attributes(latitude: 50, checked_at: be_present)
        expect(response.body).to include('/backend/unchecked_places', 'als geprüft markiert')
      end

      it 'keeps the team unchecked without the checkbox' do
        patch "/contributions/teams/#{unchecked_team.id}/geo_position",
              params: { latitude: '50', longitude: '10', offer_check: '1' }
        expect(unchecked_team.reload).to have_attributes(latitude: 50, checked_at: nil)
      end
    end
  end
end
