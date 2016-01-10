require 'rails_helper'

describe Calculation::PerformanceOfYear::Person do
  
  describe 'calculation of single performance for one year' do
    it "returns entries" do
      hl_male = Calculation::PerformanceOfYear::Person.entries(2012, :hl, :male)
      expect(hl_male.count).to eq 17

      expect(hl_male.first.points.round).to eq 1567
      expect(hl_male.first.person.id).to eq 92
      expect(hl_male.first.valid_time_average).to eq 1625
      
      expect(hl_male.second.points.round).to eq 1623
      expect(hl_male.second.person.id).to eq 68
      expect(hl_male.second.valid_time_average).to eq 1657

      hl_female = Calculation::PerformanceOfYear::Person.entries(2012, :hl, :female)
      expect(hl_female.count).to eq 0
    end
  end
end