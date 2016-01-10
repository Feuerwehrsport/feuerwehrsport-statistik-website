require 'rails_helper'

describe Calculation::PerformanceOfYear::Team do
  
  describe 'calculation of single performance for one year' do
    it "returns entries" do
      la_male = Calculation::PerformanceOfYear::Team.entries(2012, :la, :male)
      expect(la_male.count).to eq 43

      expect(la_male.first.points.round).to eq 2191
      expect(la_male.first.team.id).to eq 20
      expect(la_male.first.valid_time_average).to eq 2181
      
      expect(la_male.second.points.round).to eq 2251
      expect(la_male.second.team.id).to eq 45
      expect(la_male.second.valid_time_average).to eq 2271

      la_female = Calculation::PerformanceOfYear::Team.entries(2012, :la, :female)
      expect(la_female.count).to eq 26
    end
  end
end