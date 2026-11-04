# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Exports (xlsx, atom, datatable json)' do
  let(:xlsx_content_type) { 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' }

  # returns sheet names and all cell strings (inline or shared)
  def xlsx_strings(body)
    zip = Zip::File.open_buffer(StringIO.new(body))
    workbook = zip.read('xl/workbook.xml').force_encoding('UTF-8')
    entries = zip.entries.select { |e| e.name.match?(%r{\Axl/(worksheets/sheet\d+|sharedStrings)\.xml\z}) }
    strings = entries.flat_map { |e| zip.read(e.name).force_encoding('UTF-8').scan(%r{<t[^>]*>([^<]*)</t>}).flatten }
    [workbook.scan(/<sheet [^>]*name="([^"]+)"/).flatten, strings]
  end

  describe 'GET /competitions/:id.xlsx' do
    let!(:score) { create(:score) }
    let!(:group_score) { create(:group_score, :double) }

    it 'returns spreadsheet with overview and disciplines' do
      create(:score, :hl, person: score.person, time: 1800)
      get "/competitions/#{score.competition_id}.xlsx"
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq xlsx_content_type

      sheets, strings = xlsx_strings(response.body)
      expect(sheets.first).to eq 'Übersicht'
      expect(sheets.size).to be >= 3
      expect(strings).to include('01.05.2017 - Charlottenthal, D-Cup (Erster Lauf)', 'Meier', 'Alfred', '19,76',
                                 '22,87')
    end
  end

  describe 'GET /bla/badges.xlsx' do
    let!(:badge) { create(:bla_badge) }

    it 'returns spreadsheet' do
      get '/bla/badges.xlsx'
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq xlsx_content_type
      sheets, _strings = xlsx_strings(response.body)
      expect(sheets).to eq ['Bundesleistungsabzeichen']
    end

    it 'returns spreadsheet with badges' do
      pending 'Bug: export_index ohne Formate (bla/badges_controller.rb:6) -> Excel-Datei enthält nur leere Zeilen'
      get '/bla/badges.xlsx'
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq xlsx_content_type
      _sheets, strings = xlsx_strings(response.body)
      expect(strings).to include('Alfred Meier', 'Silber', '19,76')
    end
  end

  describe 'GET /change_logs.atom' do
    let!(:change_log) { create(:change_log) }

    it 'returns atom feed' do
      get '/change_logs.atom'
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq 'application/atom+xml'
      feed = Nokogiri::XML(response.body)
      feed.remove_namespaces!
      expect(feed.at('feed > title').text).to eq 'Feuerwehrsport-Statistik-Veränderungen'
      expect(feed.css('entry').size).to eq 1
      expect(feed.at('entry > title').text).to eq 'Wettkämpfer hinzufügen'
      expect(feed.at('entry > author > name').text).to eq 'admin user'
      expect(feed.at('entry > content').text).to include('Roland Sommer')
    end
  end

  describe 'datatable json' do
    let(:datatable_params) do
      { draw: 3, start: 0, length: 10, search: { value: '' }, order: { '0' => { column: '0', dir: 'asc' } } }
    end

    it 'returns competitions' do
      competition = create(:competition, :fake_count)
      create(:competition, name: 'Anderer', date: Date.parse('2018-01-01'))
      get '/competitions.json', params: datatable_params.merge(datatable: 'competitions')
      expect_json_response
      expect(json_body).to include(draw: 3, recordsTotal: 2, recordsFiltered: 2)
      expect(json_body[:data].first.first).to eq '2017-05-01'
      expect(json_body[:data].first[2..5]).to eq %w[12 13 10 11]
      expect(json_body[:data].first[1]).to include("/competitions/#{competition.id}")
    end

    it 'searches and paginates teams' do
      create(:team)
      create(:team, :mv)
      get '/teams.json', params: datatable_params.merge(datatable: 'teams', length: 1, search: { value: 'Mecklen' })
      expect(json_body).to include(recordsTotal: 2, recordsFiltered: 1)
      expect(json_body[:data].size).to eq 1
      expect(json_body[:data].first[2]).to eq 'Team MV'
    end

    it 'returns people by gender' do
      create(:person)
      female = create(:person, :female)
      get '/people.json', params: datatable_params.merge(datatable: 'people_female')
      expect(json_body).to include(recordsTotal: 1, recordsFiltered: 1)
      expect(json_body[:data].first.first).to eq "<a href=\"/people/#{female.id}\">Meyer</a>"
    end
  end

  describe PdfSupport do
    it 'configures prawn document' do
      pending 'Bug/toter Code: configure_prawn ruft prawnto auf, das prawn-rails 1.6 nicht mehr bereitstellt'
      controller = PagesController.new
      allow(controller).to receive(:page_title).and_return('Test Titel')
      expect { controller.configure_prawn }.not_to raise_error
    end
  end
end
