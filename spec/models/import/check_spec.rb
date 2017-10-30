require 'rails_helper'

describe Import::Check do
  describe '' do
    it 'validation' do
      import = Import::Check.new
      expect(import).to_not be_valid
      expect(import).to have(2).errors_on(:headline_columns)
      expect(import).to have(2).errors_on(:discipline)
      expect(import).to have(2).errors_on(:gender)
      expect(import).to have(1).errors_on(:separator)
      expect(import).to have(1).errors_on(:lines)

      import = Import::Check.new(
        discipline: 'la',
        gender: 'male',
        raw_headline_columns: 'team',
      )
      expect(import).to_not be_valid
      expect(import).to have(2).errors_on(:headline_columns)
      expect(import).to have(1).errors_on(:lines)

      import = Import::Check.new(
        discipline: 'la',
        gender: 'male',
        raw_headline_columns: 'team|col',
        separator: '|',
      )
      expect(import).to_not be_valid
      expect(import).to have(1).errors_on(:headline_columns)
      expect(import).to have(1).errors_on(:lines)

      import = Import::Check.new(
        discipline: 'la',
        gender: 'male',
        raw_headline_columns: 'team|time',
        separator: '|',
        raw_lines: "foo|bar\nteam|foo",
      )
      expect(import).to be_valid
      import.separator = "\t"
      expect(import).to_not be_valid
      expect(import).to have(0).errors_on(:separator)

      import = Import::Check.new(
        discipline: 'la',
        gender: 'male',
        raw_headline_columns: 'team|time',
        separator: '|',
        raw_lines: 'foo|bar|team|foo',
      )
      expect(import).to_not be_valid
      expect(import).to have(1).errors_on(:raw_lines)
    end
  end

  describe '.import_lines!' do
    let!(:person) { create(:person) }
    let!(:team) { create(:team) }
    let(:raw_lines) { 'Meier;Alfred;FF Warin;19,22;18,99' }
    let(:raw_headline_columns) { 'last_name;first_name;team;time;time' }
    let(:check) do
      Import::Check.new(
        discipline: 'la',
        gender: 'male',
        raw_headline_columns: raw_headline_columns,
        separator: ';',
        raw_lines: raw_lines,
      )
    end
    it '' do
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
