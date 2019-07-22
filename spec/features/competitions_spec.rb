require 'rails_helper'

describe 'competitions features', type: :feature, js: true do
  let(:competition) do
    create(:competition, :score_type)
    group_score = create(:group_score, :double)
    create(:score, :double, competition: group_score.competition)
    create(:score, :double, competition: group_score.competition, discipline: :hl).competition
  end

  context 'index' do
    it 'shows an overview' do
      competition
      create_list(:competition, 12)

      visit competitions_path
      expect(page).to have_content '1 bis 10 von 13 Einträgen'
      save_review_screenshot
      click_on 'Nächste'
      expect(page).to have_content '11 bis 13 von 13 Einträgen'
      click_on 'Zurück'
      expect(page).to have_content '1 bis 10 von 13 Einträgen'

      expect(page).to have_link 'Alfred Meier'
      expect(page).not_to have_content 'FF Warin'
      find('img[title="Löschangriff nass"]').click
      expect(page).to have_link 'FF Warin'
      expect(page).not_to have_content 'Alfred Meier'
    end
  end

  context 'show' do
    it 'shows the competition' do
      visit competition_path(competition)

      expect(page).not_to have_content('Hindernisbahn weiblich')
      expect(page).not_to have_content('Hindernisbahn weiblich Mannschaftswertung')

      save_review_screenshot

      expect(page).to have_content('Hindernisbahn männlich')
      expect(page).to have_content('1 bis 1 von 1 Einträgen')
      expect(page).to have_content('Hindernisbahn männlich Mannschaftswertung')

      expect(page).not_to have_content('Hakenleitersteigen weiblich')
      expect(page).not_to have_content('Hakenleitersteigen weiblich Mannschaftswertung')

      expect(page).to have_content('Hakenleitersteigen männlich')
      expect(page).to have_content('Hakenleitersteigen männlich Mannschaftswertung')

      expect(page).not_to have_content('Zweikampf weiblich')
      expect(page).to have_content('Zweikampf männlich')

      expect(page).not_to have_content('Löschangriff nass weiblich')
      expect(page).to have_content('Löschangriff nass männlich')
      expect(page).to have_content('Standardwertung WKO')

      within('.missed-3') do
        expect(page).to have_content('Folgende Informationen fehlen:')
      end
    end

    it 'shows the competition' do
      visit competition_path(id: competition.id, format: :xlsx)
      expect(page.response_headers['Content-Type']).to eq(
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet; charset=utf-8',
      )
    end

    it 'adds change requests', retry: 3 do
      api_sign_in

      visit competition_path(competition)
      find('#add-change-request').click

      within('.fss-window') do
        expect(page).to have_content('Auswahl des Fehlers')
        choose('Name des Wettkampfs vorschlagen')
        click_on('OK')
      end

      within('.fss-window') do
        expect(page).to have_content('Namen vorschlagen')
        fill_in 'Name', with: 'Superduperwettkampf'
        save_review_screenshot
        click_on('OK')
      end
      expect(page).to have_content('Der Fehlerbericht wurde gespeichert')
      click_on('OK')

      change_request_content = ChangeRequest.last.content
      expect(change_request_content).to include key: 'competition-change-name'
      expect(change_request_content[:data]).to eq(competition_id: competition.id.to_s, name: 'Superduperwettkampf')

      find('#add-change-request').click

      within('.fss-window') do
        expect(page).to have_content('Auswahl des Fehlers')
        choose('Hinweis geben')
        click_on('OK')
      end

      within('.fss-window') do
        expect(page).to have_content('Hinweis beschreiben')
        fill_in 'Beschreibung', with: 'Wetterbericht'
        save_review_screenshot
        click_on('OK')
      end
      expect(page).to have_content('Der Fehlerbericht wurde gespeichert')
      click_on('OK')

      change_request_content = ChangeRequest.last.content
      expect(change_request_content).to include key: 'competition-add-hint'
      expect(change_request_content[:data]).to eq(competition_id: competition.id.to_s, hint: 'Wetterbericht')
    end
  end

  context 'file upload' do
    it 'adds change requests', retry: 3 do
      api_sign_in

      visit competition_path(competition)
      find('#add-file').click

      expect(page).to have_content('Es dürfen nur PDFs hochgeladen werden.')
      attach_file('competition_file[0][file]', "#{Rails.root}/spec/fixtures/testfile.pdf")
      check('competition_file[0][fs_female]')
      click_on('Hochladen')
      expect(page).to have_content('testfile.pdf')
    end
  end
end
