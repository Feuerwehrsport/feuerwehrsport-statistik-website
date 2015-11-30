require 'rails_helper'

describe Calculation::PerformanceOfYear::Person do
  
  describe 'calculation of single performance for one year' do
    it "returns entries" do
      hl_male = Calculation::PerformanceOfYear::Person.entries(2014, :hl, :male)
      expect(hl_male.count).to eq 114

      expect(hl_male.first.points.round).to eq 1506
      expect(hl_male.first.person.id).to eq 184
      expect(hl_male.first.valid_time_average).to eq 1597
      
      expect(hl_male.second.points.round).to eq 1518
      expect(hl_male.second.person.id).to eq 100
      expect(hl_male.second.valid_time_average).to eq 1606

      hl_female = Calculation::PerformanceOfYear::Person.entries(2014, :hl, :female)
      expect(hl_female.count).to eq 43
    end
  end
end