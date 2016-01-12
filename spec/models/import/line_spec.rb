require 'rails_helper'

describe Import::Line do
  let(:raw_lines) { "" }
  let(:raw_headline_columns) { "" }
  let(:check) { Import::Check.new(discipline: "hb", gender: "male", raw_headline_columns: raw_headline_columns, separator: ";", raw_lines: raw_lines) }
  let(:line) { Import::Line.new(check, []) }

  describe '.initialize' do
    let(:raw_lines) { "Rost;Hannes;FF Charlottenthal;19,22;18,99" }
    let(:raw_headline_columns) { "last_name;first_name;team;time;time" }
    let(:line) { Import::Line.new(check, check.lines.first) }
    before { check.valid? }

    it "generates out-hash" do
      expect(line.out.to_h).to eq(
        valid: true, 
        last_name: "Rost", 
        first_name: "Hannes", 
        times: [1922, 1899], 
        team_names: ["Charlottenthal"], 
        original_team: "FF Charlottenthal", 
        run: "A", 
        team_number: 1, 
        team_ids: [46],
        people: [[68, "Rost", "Hannes"]]
      )
    end
  end


  describe '.normalize_team_run' do
    it "checks return values of normalize_team_run" do
      expect(line.send(:normalize_team_run, "")).to eq "A"
      expect(line.send(:normalize_team_run, "Team MV A")).to eq "A"
      expect(line.send(:normalize_team_run, "Team MV B")).to eq "B"
      expect(line.send(:normalize_team_run, "Team MV C")).to eq "C"
      expect(line.send(:normalize_team_run, "Team MV D")).to eq "D"
      expect(line.send(:normalize_team_run, "Team MV B C B")).to eq "B"
    end
  end

  describe '.normalize_time' do
    it "checks return values of normalize_time" do
      expect(line.send(:normalize_time, "")).to be false
      expect(line.send(:normalize_time, "D")).to be TimeInvalid::INVALID

      expect(line.send(:normalize_time, 'N')).to be false
      expect(line.send(:normalize_time, 'asdf')).to be false
      expect(line.send(:normalize_time, 'D')).to be TimeInvalid::INVALID
      expect(line.send(:normalize_time, '999')).to be TimeInvalid::INVALID

      expect(line.send(:normalize_time, '4,10')).to be TimeInvalid::INVALID
      expect(line.send(:normalize_time, '12,30')).to be 1230
      expect(line.send(:normalize_time, '61,60')).to be 6160
      expect(line.send(:normalize_time, '99,99')).to be 9999
      expect(line.send(:normalize_time, '999,99')).to be TimeInvalid::INVALID
    
      expect(line.send(:normalize_time, '4:10')).to be TimeInvalid::INVALID
      expect(line.send(:normalize_time, '12:30')).to be 1230
      expect(line.send(:normalize_time, '61:60')).to be 6160
      expect(line.send(:normalize_time, '99:99')).to be 9999
      expect(line.send(:normalize_time, '999:99')).to be TimeInvalid::INVALID
    
      expect(line.send(:normalize_time, '4;10')).to be TimeInvalid::INVALID
      expect(line.send(:normalize_time, '12;30')).to be 1230
      expect(line.send(:normalize_time, '61;60')).to be 6160
      expect(line.send(:normalize_time, '99;99')).to be 9999
      expect(line.send(:normalize_time, '999;99')).to be TimeInvalid::INVALID
    
      expect(line.send(:normalize_time, '4.10')).to be TimeInvalid::INVALID
      expect(line.send(:normalize_time, '12.30')).to be 1230
      expect(line.send(:normalize_time, '61.60')).to be 6160
      expect(line.send(:normalize_time, '99.99')).to be 9999
      expect(line.send(:normalize_time, '999.99')).to be TimeInvalid::INVALID

      expect(line.send(:normalize_time, '1:31:12')).to be 9112
      expect(line.send(:normalize_time, '1:31,12')).to be 9112
    end
  end

  describe '.normalize_team_number' do
    it "checks return values of normalize_team_number" do
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
    before do
      TeamSpelling.create!(
        team_id: 99,
        name: "FF Merzdorf",
        shortcut: "Merzdorf",
      )
    end
    it "checks return values of find_teams" do
      expect(line.send(:find_teams, 'FF Warin').map(&:id)).to eq [59]
      expect(line.send(:find_teams, 'Team MV 1').map(&:id)).to eq [2]
      expect(line.send(:find_teams, 'Team MV 2').map(&:id)).to eq [2]
      expect(line.send(:find_teams, 'Team MV 3').map(&:id)).to eq [2]
      expect(line.send(:find_teams, 'Team MV 4').map(&:id)).to eq [2]
      expect(line.send(:find_teams, 'Team MV E').map(&:id)).to eq [2]
      expect(line.send(:find_teams, 'Team MV I').map(&:id)).to eq [2]
      expect(line.send(:find_teams, 'Team MV II').map(&:id)).to eq [2]
      expect(line.send(:find_teams, 'Team MV III').map(&:id)).to eq [2]
      expect(line.send(:find_teams, 'Team MV IV').map(&:id)).to eq [2]
      expect(line.send(:find_teams, 'FF Merzdorf').map(&:id)).to eq [45, 99]
    end
  end

  describe '.find_people' do
    it "checks return values of find_people" do
      line.out.last_name = "Krause"
      line.out.first_name = "Roman"
      expect(line.send(:find_people)).to eq [[64, "Krause", "Roman"]]

      PersonSpelling.create!(
        person_id: 65,
        last_name: "Krause",
        first_name: "Roman",
        gender: :male,
      )
      expect(line.send(:find_people)).to eq [[64, "Krause", "Roman"], [65, "Jahrmatter", "Thomas"]]
    end
  end  
end