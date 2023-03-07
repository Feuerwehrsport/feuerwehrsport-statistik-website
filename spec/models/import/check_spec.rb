# frozen_string_literal: true

require 'rails_helper'

describe Import::Check do
  describe '' do
    it 'validation' do
      import = described_class.new
      expect(import).not_to be_valid
      expect(import.errors[:headline_columns].count).to eq 2
      expect(import.errors[:discipline].count).to eq 2
      expect(import.errors[:gender].count).to eq 2
      expect(import.errors[:separator].count).to eq 1
      expect(import.errors[:lines].count).to eq 1

      import = described_class.new(
        discipline: 'la',
        gender: 'male',
        raw_headline_columns: 'team',
      )
      expect(import).not_to be_valid
      expect(import.errors[:headline_columns].count).to eq 2
      expect(import.errors[:lines].count).to eq 1

      import = described_class.new(
        discipline: 'la',
        gender: 'male',
        raw_headline_columns: 'team|col',
        separator: '|',
      )
      expect(import).not_to be_valid
      expect(import.errors[:headline_columns].count).to eq 1
      expect(import.errors[:lines].count).to eq 1

      import = described_class.new(
        discipline: 'la',
        gender: 'male',
        raw_headline_columns: 'team|time',
        separator: '|',
        raw_lines: "foo|bar\nteam|foo",
      )
      expect(import).to be_valid
      import.separator = "\t"
      expect(import).not_to be_valid
      expect(import.errors[:separator].count).to eq 0

      import = described_class.new(
        discipline: 'la',
        gender: 'male',
        raw_headline_columns: 'team|time',
        separator: '|',
        raw_lines: 'foo|bar|team|foo',
      )
      expect(import).not_to be_valid
      expect(import.errors[:raw_lines].count).to eq 1
    end
  end

  describe '.import_lines!' do
    let!(:person) { create(:person) }
    let!(:team) { create(:team) }
    let(:raw_lines) { 'Meier;Alfred;FF Warin;19,22;18,99' }
    let(:raw_headline_columns) { 'last_name;first_name;team;time;time' }
    let(:check) do
      described_class.new(
        discipline: 'la',
        gender: 'male',
        raw_headline_columns: raw_headline_columns,
        separator: ';',
        raw_lines: raw_lines,
      )
    end

    it 'generates correct results' do
      expect(check.import_lines!.map(&:to_h)).to eq(
        [
          valid: true,
          last_name: 'Meier',
          first_name: 'Alfred',
          times: [1922, 1899],
          team_names: ['Warin'],
          original_team: 'FF Warin',
          run: 'A',
          team_number: 1,
          team_ids: [team.id],
          people: [[person.id, 'Meier', 'Alfred']],
        ],
      )
    end
  end
end
