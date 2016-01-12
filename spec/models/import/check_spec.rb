require 'rails_helper'

describe Import::Check do
  describe '' do
    it "validation" do
      import = Import::Check.new
      expect(import).to_not be_valid
      expect(import).to have(2).errors_on(:headline_columns)
      expect(import).to have(2).errors_on(:discipline)
      expect(import).to have(2).errors_on(:gender)
      expect(import).to have(1).errors_on(:seperator)
      expect(import).to have(1).errors_on(:lines)

      import = Import::Check.new(discipline: "la", gender: "male", raw_headline_columns: "team")
      expect(import).to_not be_valid
      expect(import).to have(2).errors_on(:headline_columns)
      expect(import).to have(1).errors_on(:lines)

      import = Import::Check.new(discipline: "la", gender: "male", raw_headline_columns: "team|col", seperator: "|")
      expect(import).to_not be_valid
      expect(import).to have(1).errors_on(:headline_columns)
      expect(import).to have(1).errors_on(:lines)

      import = Import::Check.new(discipline: "la", gender: "male", raw_headline_columns: "team|time", seperator: "|", raw_lines: "foo|bar\nteam|foo")
      expect(import).to be_valid
    end
  end

  describe '.import_lines!' do
    let(:raw_lines) { "Rost;Hannes;FF Charlottenthal;19,22;18,99" }
    let(:raw_headline_columns) { "last_name;first_name;team;time;time" }
    let(:check) { Import::Check.new(discipline: "la", gender: "male", raw_headline_columns: raw_headline_columns, seperator: ";", raw_lines: raw_lines) }
    it '' do
      expect(check.import_lines!.map(&:to_h)).to eq(
        [
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
        ]
      )
    end
  end
end