# frozen_string_literal: true

require 'rails_helper'

describe ImportRequest do
  let(:import_request) { build(:import_request, import_request_files: []) }

  describe 'scopes and cleanup' do
    let!(:open_request) { create(:import_request, import_request_files: []) }
    let!(:finished_request) { create(:import_request, import_request_files: [], finished_at: 1.month.ago) }

    it 'orders open requests first and finds open requests' do
      expect(described_class.open).to eq [open_request]
      expect(described_class.all.to_a).to eq [open_request, finished_request]
    end

    it 'removes finished requests older than three months after create' do
      old_request = create(:import_request, import_request_files: [])
      old_request.update_column(:finished_at, 4.months.ago)
      expect(described_class.old_entries).to eq [old_request]

      new_request = create(:import_request, import_request_files: [])

      expect(described_class.pluck(:id)).to contain_exactly(open_request.id, finished_request.id, new_request.id)
    end
  end

  describe '#edit_user_id=' do
    let(:edit_user) { create(:admin_user, :sub_admin) }

    it 'sets and resets edited_at' do
      travel_to(Time.zone.local(2020, 1, 2, 3, 4, 5)) do
        import_request.edit_user_id = edit_user.id
        expect(import_request.edited_at).to eq Time.zone.local(2020, 1, 2, 3, 4, 5)
      end
      import_request.save!

      import_request.edit_user_id = ''
      expect(import_request.edit_user_id).to be_nil
      expect(import_request.edited_at).to be_nil
    end

    it 'does not touch edited_at if edit user is unchanged' do
      import_request.edit_user_id = edit_user.id
      import_request.save!
      import_request.edited_at = 1.year.ago
      import_request.edit_user_id = edit_user.id
      expect(import_request.edited_at).to be_within(1.second).of(1.year.ago)
    end
  end

  describe '#finished' do
    it 'sets finished_at from form value' do
      expect(import_request.finished).to be false

      travel_to(Time.zone.local(2020, 1, 2, 3, 4, 5)) do
        import_request.finished = '1'
        expect(import_request.finished_at).to eq Time.zone.local(2020, 1, 2, 3, 4, 5)
      end
      expect(import_request.finished).to be true

      import_request.finished = '0'
      expect(import_request.finished_at).to be_nil
      expect(import_request.finished).to be false
    end
  end

  describe '#import_data' do
    it 'returns indifferent access hash' do
      expect(import_request.import_data).to be_nil

      import_request.import_data = { 'name' => 'Foo' }
      expect(import_request.import_data[:name]).to eq 'Foo'
      expect(import_request.import_data['name']).to eq 'Foo'
    end
  end

  describe '#import_data_results' do
    it 'returns only results with more than one row' do
      import_request.import_data = {
        results: [
          { discipline: 'hb', rows: [{ a: 1 }] },
          { discipline: 'hl', rows: [{ a: 1 }, { a: 2 }] },
          { discipline: 'la', rows: [] },
        ],
      }
      expect(import_request.import_data_results.pluck(:discipline)).to eq ['hl']
    end
  end

  describe '#import_data_series_rounds' do
    let(:round) { create(:series_round) }
    let(:other_round) { create(:series_round, year: 2017) }
    let(:unused_round) { create(:series_round, year: 2018) }

    it 'returns the series rounds referenced by the round keys' do
      unused_round
      import_request.import_data = {
        results: [
          { rows: [1, 2], series_person_round_keys: ["#{round.id}-female"], series_team_round_keys: nil },
          {
            rows: [1, 2],
            series_person_round_keys: ["#{round.id}-male"],
            series_team_round_keys: ["#{other_round.id}-female"],
          },
          { rows: [1], series_team_round_keys: ["#{unused_round.id}-female"] },
          { rows: [1, 2] },
        ],
      }
      expect(import_request.import_data_series_rounds).to contain_exactly(round, other_round)
    end
  end

  describe 'points corrections' do
    before do
      import_request.import_data = {
        person_points_corrections: [
          { round_key: '1-female', person_id: 5, points: 3 },
          { round_key: '1-male', person_id: 5, points: 4 },
        ],
        team_points_corrections: [
          { round_key: '1-female', team_id: 7, team_number: 1, discipline: 'la', points: 10 },
          { round_key: '1-female', team_id: 7, team_number: 2, discipline: 'la', points: 11 },
        ],
      }
    end

    it 'finds matching person correction' do
      expect(import_request.person_points_corrections('1-male', 5)[:points]).to eq 4
      expect(import_request.person_points_corrections('1-male', 6)).to be_nil
    end

    it 'finds matching team correction' do
      expect(import_request.team_points_corrections('1-female', 7, 2, 'la')[:points]).to eq 11
      expect(import_request.team_points_corrections('1-female', 7, 2, 'fs')).to be_nil
    end

    it 'handles missing corrections' do
      import_request.import_data = {}
      expect(import_request.person_points_corrections('1-male', 5)).to be_nil
      expect(import_request.team_points_corrections('1-female', 7, 2, 'la')).to be_nil
    end
  end

  describe '#competition_info' do
    it 'uses import data and falls back to attributes' do
      expect(import_request.competition_info).to eq(
        place: 'Charlottenthal',
        event: 'D-Cup',
        date: '2013-09-21',
      )

      import_request.import_data = { name: 'Name', place: 'Ort', date: '2020-01-01', results: [1] }
      expect(import_request.competition_info).to eq(
        'name' => 'Name',
        'place' => 'Ort',
        'event' => 'D-Cup',
        'date' => '2020-01-01',
      )
    end

    it 'works without place, event and date' do
      expect(described_class.new.competition_info).to eq({})
    end
  end

  describe '#compressed_data=' do
    let(:result_json) { { discipline: 'hb', gender: 'male', rows: [1, 2] }.to_json }
    let(:export_hash) do
      {
        files: [
          { name: 'result.json', mimetype: Mime[:json].to_s, base64_data: Base64.encode64(result_json) },
          { name: 'other.json', mimetype: Mime[:json].to_s, base64_data: Base64.encode64('{"test":"data"}') },
          { name: 'list.pdf', mimetype: Mime[:pdf].to_s, base64_data: Base64.encode64('%PDF-1.4') },
        ],
        name: 'Wettkampf-Name',
        date: '2020-05-06',
        place: 'Ort',
        user: 'Hans',
        user_email_address: 'hans@example.com',
        url: 'https://example.com/results',
        hint: 'Hinweis',
        person_points_corrections: [{ round_key: '1-male', person_id: 1 }],
        team_points_corrections: [],
      }
    end
    let(:compressed_data) { Base64.encode64(Zlib::Deflate.deflate(export_hash.to_json)) }

    it 'extracts data, results and files' do
      import_request.compressed_data = compressed_data

      expect(import_request.date).to eq Date.new(2020, 5, 6)
      expect(import_request.url).to eq 'https://example.com/results'
      expect(import_request.description).to eq <<~STRING
        Name: Wettkampf-Name
        Datum: 2020-05-06
        Ort: Ort
        Nutzer: Hans
        E-Mail-Adresse: hans@example.com
        URL: https://example.com/results

        Hinweis
      STRING

      expect(import_request.import_data).to eq(
        'date' => '2020-05-06',
        'name' => 'Wettkampf-Name',
        'place' => 'Ort',
        'results' => [{ 'discipline' => 'hb', 'gender' => 'male', 'rows' => [1, 2] }],
        'person_points_corrections' => [{ 'round_key' => '1-male', 'person_id' => 1 }],
        'team_points_corrections' => [],
      )

      files = import_request.import_request_files
      expect(files.map { |f| f.file.filename }).to eq %w[other.json list.pdf]
      expect(files.last.file.read).to eq '%PDF-1.4'
    end

    it 'works without files' do
      export_hash.delete(:files)
      import_request.compressed_data = compressed_data
      expect(import_request.import_request_files).to be_empty
      expect(import_request.import_data[:results]).to eq []
    end
  end

  describe 'nested import request files' do
    it 'rejects files without upload' do
      import_request.import_request_files_attributes = [{ file: '' }]
      expect(import_request.import_request_files).to be_empty
    end
  end
end
