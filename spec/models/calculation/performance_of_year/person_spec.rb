require 'rails_helper'

describe Calculation::PerformanceOfYear::Person do
  describe 'calculation of single performance for one year' do
    let!(:score1) { create(:score, :double) }
    let!(:score2) { create(:score, :double, time: Firesport::INVALID_TIME) }

    it 'returns entries' do
      hl_male = described_class.entries(score1.competition.date.year, :hb, :male)
      expect(hl_male.count).to eq 1

      expect(hl_male.first.points.round).to eq 2037
      expect(hl_male.first.person.id).to eq score1.person_id
      expect(hl_male.first.valid_time_average).to eq 2052

      hl_female = described_class.entries(2012, :hl, :female)
      expect(hl_female.count).to eq 0
    end
  end
end
