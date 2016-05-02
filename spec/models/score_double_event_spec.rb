require 'rails_helper'

RSpec.describe ScoreDoubleEvent, type: :model do
  let(:male) { described_class.new(time: 10, person: Person.find(40), hb: 5, hl: 5) }
  let(:male_slow) { described_class.new(time: 11, person: Person.first, hb: 5, hl: 6) }
  let(:male_hb_slow) { described_class.new(time: 10, person: Person.first, hb: 6, hl: 4) }
  let(:female) { described_class.new(time: 10, person: Person.first, hb: 5, hl: 5) }
  let(:female_slow) { described_class.new(time: 11, person: Person.first, hb: 5, hl: 6) }
  let(:female_hb_slow) { described_class.new(time: 10, person: Person.first, hb: 6, hl: 4) }
  it "sorts" do
    expect(male.person.gender).to eq "male"
    expect(male <=> male).to eq 0
    expect(male <=> male_slow).to eq -1
    expect(male <=> male_hb_slow).to eq 1

    expect(female.person.gender).to eq "female"
    expect(female <=> female).to eq 0
    expect(female <=> female_slow).to eq -1
    expect(female <=> female_hb_slow).to eq -1
  end
end
