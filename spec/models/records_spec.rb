# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Records do
  describe 'config/records.yml' do
    let(:records) { described_class.load }

    it 'has a date and valid entries' do
      expect(records.updated_on).to be_a(Date)
      records.groups.flat_map(&:records).each do |record|
        expect(record.discipline).to be_in(%i[hl hb zk gs fs la])
        expect(record.time).to match(/\A\d+,\d\d\z/)
      end
    end

    it 'has a current German record for every discipline of the start page' do
      %i[hl hb fs la].each do |discipline|
        expect(records.german(discipline, :male)).to be_present, "#{discipline} male"
      end
      %i[hl hb gs fs la].each do |discipline|
        expect(records.german(discipline, :female)).to be_present, "#{discipline} female"
      end
    end
  end

  describe 'with records of the database' do
    let(:person) { create(:person) }
    let(:team) { create(:team) }
    let(:competition) { create(:competition) }
    let(:data) do
      {
        'updated_on' => Date.new(2026, 1, 29),
        'groups' => [{
          'key' => 'german_female', 'title' => 'Deutsche Rekorde – Frauen', 'gender' => 'female', 'scope' => 'german',
          'records' => [
            { 'discipline' => 'hb', 'time' => '18,20', 'historic' => true, 'people' => [person.id], 'team' => team.id },
            { 'discipline' => 'hb', 'time' => '17,47', 'people' => [person.id, 0], 'team' => team.id,
              'competition' => competition.id },
          ]
        }],
      }
    end
    let(:records) { described_class.new(data) }

    it 'returns the current record and skips records under old rules' do
      record = records.german(:hb, :female)
      expect(record.time).to eq '17,47'
      expect(record.people.map(&:id)).to eq [person.id] # unknown id 0 is skipped
      expect(record.team.id).to eq team.id
      expect(record.competition.id).to eq competition.id
      expect(records.german(:hb, :male)).to be_nil
    end
  end
end
