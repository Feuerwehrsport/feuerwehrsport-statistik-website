# frozen_string_literal: true

require 'rails_helper'

describe Import::Line do
  let!(:person) { create(:person) }
  let!(:team) { create(:team) }
  let(:raw_lines) { '' }
  let(:raw_headline_columns) { '' }
  let(:check) do
    Import::Check.new(
      discipline: 'hb',
      gender: 'male',
      raw_headline_columns:,
      separator: ';',
      raw_lines:,
    )
  end
  let(:line) { described_class.new(check, []) }

  describe '.initialize' do
    let(:raw_lines) { 'Meier;Alfred;FF Warin;19,22;18,99' }
    let(:raw_headline_columns) { 'last_name;first_name;team;time;time' }
    let(:line) { described_class.new(check, check.lines.first) }

    before { check.valid? }

    it 'generates out-hash' do
      expect(line.out).to eq(
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
      )
    end
  end

  describe '.normalize_team_run' do
    it 'checks return values of normalize_team_run' do
      expect(line.send(:normalize_team_run, '')).to eq 'A'
      expect(line.send(:normalize_team_run, 'Team MV A')).to eq 'A'
      expect(line.send(:normalize_team_run, 'Team MV B')).to eq 'B'
      expect(line.send(:normalize_team_run, 'Team MV C')).to eq 'C'
      expect(line.send(:normalize_team_run, 'Team MV D')).to eq 'D'
      expect(line.send(:normalize_team_run, 'Team MV B C B')).to eq 'B'
    end
  end

  describe '.normalize_time' do
    it 'checks return values of normalize_time' do
      expect(line.send(:normalize_time, '')).to be false
      expect(line.send(:normalize_time, 'D')).to be Firesport::INVALID_TIME

      expect(line.send(:normalize_time, 'N')).to be false
      expect(line.send(:normalize_time, 'asdf')).to be false
      expect(line.send(:normalize_time, 'D')).to be Firesport::INVALID_TIME
      expect(line.send(:normalize_time, '999')).to be Firesport::INVALID_TIME

      expect(line.send(:normalize_time, '4,10')).to be Firesport::INVALID_TIME
      expect(line.send(:normalize_time, '12,30')).to be 1230
      expect(line.send(:normalize_time, '61,60')).to be 6160
      expect(line.send(:normalize_time, '99,99')).to be 9999
      expect(line.send(:normalize_time, '999,99')).to be Firesport::INVALID_TIME

      expect(line.send(:normalize_time, '4:10')).to be Firesport::INVALID_TIME
      expect(line.send(:normalize_time, '12:30')).to be 1230
      expect(line.send(:normalize_time, '61:60')).to be 6160
      expect(line.send(:normalize_time, '99:99')).to be 9999
      expect(line.send(:normalize_time, '999:99')).to be Firesport::INVALID_TIME

      expect(line.send(:normalize_time, '4;10')).to be Firesport::INVALID_TIME
      expect(line.send(:normalize_time, '12;30')).to be 1230
      expect(line.send(:normalize_time, '61;60')).to be 6160
      expect(line.send(:normalize_time, '99;99')).to be 9999
      expect(line.send(:normalize_time, '999;99')).to be Firesport::INVALID_TIME

      expect(line.send(:normalize_time, '4.10')).to be Firesport::INVALID_TIME
      expect(line.send(:normalize_time, '12.30')).to be 1230
      expect(line.send(:normalize_time, '61.60')).to be 6160
      expect(line.send(:normalize_time, '99.99')).to be 9999
      expect(line.send(:normalize_time, '999.99')).to be Firesport::INVALID_TIME

      expect(line.send(:normalize_time, '1:31:12')).to be 9112
      expect(line.send(:normalize_time, '1:31,12')).to be 9112

      expect(line.send(:normalize_time, '20,2')).to be 2020
    end
  end

  describe '.normalize_team_number' do
    it 'checks return values of normalize_team_number' do
      expect(line.send(:normalize_team_number, '1234')).to be 1
      expect(line.send(:normalize_team_number, 'foobar 1')).to be 1
      expect(line.send(:normalize_team_number, 'foobar I')).to be 1
      expect(line.send(:normalize_team_number, 'foobar 2')).to be 2
      expect(line.send(:normalize_team_number, 'foobar II')).to be 2
      expect(line.send(:normalize_team_number, 'foobar 3')).to be 3
      expect(line.send(:normalize_team_number, 'foobar III')).to be 3
      expect(line.send(:normalize_team_number, 'foobar 4')).to be 4
      expect(line.send(:normalize_team_number, 'foobar IV')).to be 4
      expect(line.send(:normalize_team_number, 'foobar E')).to be 0
    end
  end

  describe '.find_teams' do
    let!(:mv) { create(:team, :mv) }
    let!(:team_spelling1) { create(:team_spelling) }
    let!(:team_spelling2) { create(:team_spelling, team: mv, shortcut: 'MV') }
    let!(:team_spelling3) { create(:team_spelling, team: mv) }

    it 'checks return values of find_teams' do
      expect(line.send(:find_teams, 'FF Warin').map(&:id)).to eq [team.id]
      expect(line.send(:find_teams, 'Team MV 1').map(&:id)).to eq [mv.id]
      expect(line.send(:find_teams, 'Team MV 2').map(&:id)).to eq [mv.id]
      expect(line.send(:find_teams, 'Team MV 3').map(&:id)).to eq [mv.id]
      expect(line.send(:find_teams, 'Team MV 4').map(&:id)).to eq [mv.id]
      expect(line.send(:find_teams, 'Team MV E').map(&:id)).to eq [mv.id]
      expect(line.send(:find_teams, 'Team MV I').map(&:id)).to eq [mv.id]
      expect(line.send(:find_teams, 'Team MV II').map(&:id)).to eq [mv.id]
      expect(line.send(:find_teams, 'Team MV III').map(&:id)).to eq [mv.id]
      expect(line.send(:find_teams, 'Team MV IV').map(&:id)).to eq [mv.id]
      expect(line.send(:find_teams, 'FF Warino').map(&:id)).to eq [team.id, mv.id]
    end
  end

  describe '.find_people' do
    let(:female_person) { create(:person, :female) }

    it 'checks return values of find_people' do
      line.out[:last_name] = 'Meier'
      line.out[:first_name] = 'Alfred'
      expect(line.send(:find_people)).to eq [[person.id, 'Meier', 'Alfred']]

      PersonSpelling.create!(
        person: female_person,
        last_name: 'Meier',
        first_name: 'Alfred',
        gender: :male,
      )
      expect(line.send(:find_people)).to eq [[person.id, 'Meier', 'Alfred'], [female_person.id, 'Meyer', 'Johanna']]
    end
  end

  describe 'branches of initialize' do
    let(:raw_headline_columns) { 'last_name;first_name;team;time;run;given_person_id;given_team_id;given_team_number' }

    before { check.valid? }

    def line_for(cols)
      described_class.new(check, cols)
    end

    it 'marks lines with too few columns as invalid' do
      out = line_for(%w[Meier Alfred]).out
      expect(out[:valid]).to be false
      expect(out[:people]).to be_nil
      expect(check.missing_teams).to eq ['']
    end

    it 'reads run and given ids' do
      out = line_for(['Meier', 'Alfred', 'FF Warin', '19,22', 'b', '12', '', '2']).out
      expect(out[:run]).to eq 'A'
      expect(out[:given_person_id]).to eq 12
      expect(out[:given_team_id]).to be_nil
      expect(out[:given_team_number]).to eq 2
      expect(out[:times]).to eq [1922]

      out = line_for(['Meier', 'Alfred', 'FF Warin', 'n', 'x', '', '', '']).out
      expect(out[:run]).to eq 'A'
      expect(out[:times]).to eq []
      expect(out[:given_person_id]).to be_nil
    end

    it 'detects run and team number from team name' do
      out = line_for(['Meier', 'Alfred', 'FF Warin 2 C', '19,22', '', '', '', '']).out
      expect(out[:run]).to eq 'C'
      expect(out[:team_number]).to eq 2
      expect(out[:team_ids]).to eq [team.id]
    end

    it 'finds team with roman team number and run' do
      out = line_for(['Meier', 'Alfred', 'FF Warin II C', '19,22', '', '', '', '']).out
      expect(out[:run]).to eq 'C'
      expect(out[:team_number]).to eq 2

      pending 'Bug: Team.normalize_name entfernt römische Nummern nur am Ende, nicht vor dem Lauf-Buchstaben'
      expect(out[:team_ids]).to eq [team.id]
    end

    it 'finds team by id' do
      out = line_for(['Meier', 'Alfred', team.id.to_s, '19,22', '', '', '', '']).out
      expect(out[:team_ids]).to eq [team.id]
      expect(out[:team_names]).to eq ['Warin']
    end

    it 'uses given team id as fallback' do
      out = line_for(['Meier', 'Alfred', 'Unbekannt', '19,22', '', '', team.id.to_s, '']).out
      expect(out[:team_ids]).to eq [team.id]
      expect(out[:team_names]).to eq ['Warin']
      expect(out[:correct]).to be_nil
    end

    it 'reports missing teams' do
      out = line_for(['Meier', 'Alfred', 'Unbekannt', '19,22', '', '', '9999999', '']).out
      expect(out[:team_ids]).to be_nil
      expect(out[:correct]).to be false
      expect(check.missing_teams).to eq ['Unbekannt']

      line_for(['Meier', 'Alfred', 'Unbekannt', '19,22', '', '', '', ''])
      expect(check.missing_teams).to eq ['Unbekannt']
    end

    it 'strips commas from names' do
      out = line_for([',Meier,', 'Alfred,', 'FF Warin', '19,22', '', '', '', '']).out
      expect(out[:last_name]).to eq 'Meier'
      expect(out[:first_name]).to eq 'Alfred'
      expect(out[:people]).to eq [[person.id, 'Meier', 'Alfred']]
    end
  end

  describe 'group discipline' do
    let(:check) do
      Import::Check.new(discipline: 'la', gender: 'male', raw_headline_columns: 'team;time', separator: ';',
                        raw_lines: '')
    end

    before { check.valid? }

    it 'does not search people' do
      pending 'Bug: Discipline.group?(check) statt Discipline.group?(check.discipline) in Import::Line#initialize'
      out = described_class.new(check, ['FF Warin', '22,00']).out
      expect(out[:times]).to eq [2200]
      expect(out[:team_ids]).to eq [team.id]
      expect(out).not_to have_key(:people)
    end
  end
end
