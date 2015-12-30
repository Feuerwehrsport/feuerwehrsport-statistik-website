require 'rails_helper'

describe "people", type: :feature, js: true, driver: :webkit do
  it "can add person" do
    api_sign_in

    # add one
    visit people_path
    find("#add-person").click
    within('.fss-window') do
      expect(page).to have_content("Person hinzufügen")
      fill_in "Vorname", with: "Vorname"
      fill_in "Nachname", with: "00AABBCC"
      select('weiblich', from: 'Geschlecht')
      select('Österreich', from: 'Nation')
      click_on("OK")
    end
    expect(page).to have_content("00AABBCC")
    expect(page).to have_content("Vorname")

    person = Person.where(last_name: "00AABBCC")
    expect(person.count).to eq 1
    expect(person.first.attributes.symbolize_keys).to include(
      last_name: "00AABBCC",
      first_name: "Vorname",
      gender: 0,
      nation_id: 2,
    )
  end
end