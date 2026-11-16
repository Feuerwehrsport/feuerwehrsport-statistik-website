# frozen_string_literal: true

require 'rails_helper'

describe 'backend team score moves' do
  it 'moves selected scores after confirmation' do
    source = create(:team)
    destination = create(:team, name: 'FF Ziel', shortcut: 'Ziel')
    score = create(:score, team: source)
    create(:score, team: source)

    sign_in(:sub_admin)
    visit new_backend_repairs_team_score_move_path(
      repairs_team_score_move: { source_team_id: source.id, destination_team_id: destination.id },
    )
    click_on 'Weiter'

    find_by_id("move-score_ids-#{score.id}").click
    accept_confirm(/wirklich von FF Warin nach FF Ziel/) { click_on 'Ausgewählte Zeiten verschieben' }
    expect(page).to have_text('1 Zeiten von FF Warin nach FF Ziel verschoben.')
    expect(score.reload.team).to eq destination
  end
end
