# frozen_string_literal: true

require 'rails_helper'

describe 'backend series rounds' do
  it 'opens an entry from the round page and moves it up' do
    # team assessment "Männer" of the factory round counts with one participation
    assessment = create(:series_team_assessment, key: 'male')
    participation = create(:series_team_participation, team_assessment: assessment, team_gender: 1)
    round = participation.cup.round

    sign_in(:admin)
    visit backend_series_round_path(round)
    find('#edit-series-participations .series-participation', match: :first).click

    expect(page).to have_text('Eintrag bearbeiten')
    click_on '↑ Platz höher (1 Punkt mehr)'
    expect(page).to have_text('Jetzt Platz 1 mit 16 Punkten.')
    expect(page).to have_current_path(backend_series_round_path(round))
  end
end
