# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Backend::Bla::BadgeGenerators', login: :admin do
  it_behaves_like 'a backend resource controller', only: %i[new]

  describe 'GET new with candidates' do
    let(:competition) do
      create(:competition, hl_male_for_bla_badge: true, hb_male_for_bla_badge: true)
    end
    let(:person) { create(:person) }

    it 'lists people with possible badges' do
      create(:score, :hl, person:, competition:, time: 1650)
      create(:score, :hb, person:, competition:, time: 1800)
      get '/backend/bla/badge_generator/new'
      expect(response).to be_successful
      expect(response.body).to include(%(<a href="/people/#{person.id}">Alfred Meier</a>))
      expect(response.body).to match(/class="table-success">\s*OK/)
      expect(response.body).to include('16,50', '18,00')
    end
  end

  describe 'GET new.xlsx' do
    let(:competition) do
      create(:competition, hl_male_for_bla_badge: true, hb_male_for_bla_badge: true)
    end
    let(:person) { create(:person) }
    let(:other) { create(:person, first_name: 'Bernd', last_name: 'Ohnehb') }

    it 'exports only people with a badge to award, linking person and competitions' do
      create(:score, :hl, person:, competition:, time: 1650)
      create(:score, :hb, person:, competition:, time: 1800)
      create(:score, :hl, person: other, competition:, time: 1650)
      create(:score, :hb, person: other, competition:, time: 1950)
      create(:bla_badge, person: other, status: :bronze)
      create(:bla_badge, person:, status: :bronze, year: 2015)

      get '/backend/bla/badge_generator/new.xlsx'
      expect(response).to be_successful
      expect(response.media_type).to eq 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      expect(response.headers['Content-Disposition']).to include('bla-vorschlaege-')

      zip = Zip::File.open_buffer(StringIO.new(response.body))
      sheet = zip.read('xl/worksheets/sheet1.xml').force_encoding('UTF-8')
      strings = sheet.scan(%r{<t[^>]*>([^<]*)</t>}).flatten
      expect(strings).to include('Alfred Meier', 'Bronze 2015', 'Silber', '16,50', '18,00')
      expect(strings).not_to include('Bernd Ohnehb')

      rels = zip.read('xl/worksheets/_rels/sheet1.xml.rels')
      expect(rels).to include("/people/#{person.id}", "/competitions/#{competition.id}")
    end
  end

  context 'when sub admin', login: :sub_admin do
    it 'denies access' do
      get '/backend/bla/badge_generator/new'
      expect(response).to redirect_to('/')
    end
  end
end
