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
      raw_headline_columns: raw_headline_columns,
      separator: ';',
      raw_lines: raw_lines,
    )
  end
  let(:line) { described_class.new(check, []) }

  describe '.initialize' do
    let(:raw_lines) { 'Meier;Alfred;FF Warin;19,22;18,99' }
    let(:raw_headline_columns) { 'last_name;first_name;team;time;time' }
    let(:line) { described_class.new(check, check.lines.first) }

    before { check.valid? }

    it 'generates out-hash' do
      expect(line.out.to_h).to eq(
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
      line.out.last_name = 'Meier'
      line.out.first_name = 'Alfred'
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
end
