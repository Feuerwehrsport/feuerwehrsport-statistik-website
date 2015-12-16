require 'rails_helper'

describe "teams", type: :feature, js: true, driver: :webkit do
  it "can add team" do
    api_sign_in

    # add one
    visit teams_path
    find("#add-team").click
    within('.fss-window') do
      expect(page).to have_content("Mannschaft anlegen")
      fill_in "Name", with: "00Mannschaft_xyz"
      fill_in "Abkürzung", with: "Abk789"
      select('Einzelne Feuerwehr', from: 'Typ der Mannschaft')
      click_on("OK")
    end
    expect(page).to have_content("00Mannschaft_xyz")
    expect(page).to have_content("Abk789")

    team = Team.where(name: "00Mannschaft_xyz")
    expect(team.count).to eq 1
    expect(team.first.attributes.symbolize_keys).to include(
      name: "00Mannschaft_xyz",
      shortcut: "Abk789",
      status: 1,
    )
  end
end