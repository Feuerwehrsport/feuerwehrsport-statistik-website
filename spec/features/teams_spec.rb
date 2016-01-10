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

  it "can add logo" do
    api_sign_in

    visit team_path(id: 1)
    find('.upload-logo').click

    within('.fss-window') do
      attach_file('logo_files', "#{Rails.root}/spec/fixtures/testfile.pdf")
      click_on("OK")
    end
    expect(page).to have_content("Der Fehlerbericht wurde gespeichert")

    change_request = ChangeRequest.last
    expect(change_request.content).to eq(key: "team-logo", data: { team_id: "1" })
    expect(change_request.files_data).to eq(files: [ { binary: "", filename: "testfile.pdf", content_type: "application/pdf" } ]) 
  end

  it "can add geo position" do
    api_sign_in

    visit team_path(id: 6)
    within('.team-map-actions') do
      find('#add-geo-position').click
      find('.btn.btn-primary').click
    end
    expect(page).to_not have_content("Bitte warten")
    expect(page).to_not have_content("Geoposition hinzufügen")
    
    team = Team.find(6)
    expect(team.latitude).to eq 51
    expect(team.longitude).to eq 13
  end

  it "can add change request with team-merge" do
    api_sign_in

    visit team_path(id: 2)
    find('#add-change-request').click

    within('.fss-window') do
      choose("Team ist doppelt vorhanden")
      click_on("OK")

      expect(page).to have_content("Mannschaft zusammenführen")
      click_on("OK")
    end
    expect(page).to have_content("Der Fehlerbericht wurde gespeichert")

    change_request_content = ChangeRequest.last.content
    expect(change_request_content).to include key: "team-merge"
    expect(change_request_content[:data]).to eq(team_id: "2", correct_team_id: "101")
  end

  it "can add change request with team-correction" do
    api_sign_in
    visit team_path(id: 2)
    find('#add-change-request').click

    within('.fss-window') do
      choose("Team ist falsch geschrieben")
      click_on("OK")

      expect(page).to have_content("Mannschaft korrigieren")
      click_on("OK")
    end
    expect(page).to have_content("Der Fehlerbericht wurde gespeichert")

    change_request_content = ChangeRequest.last.content
    expect(change_request_content).to include key: "team-correction"
    expect(change_request_content[:data]).to eq(
      team_id: "2",
      team: { name: "Team Mecklenburg-Vorpommern", shortcut: "Team MV", status: "team" }
    )
  end
end