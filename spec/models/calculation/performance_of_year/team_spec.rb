require 'rails_helper'

describe Calculation::PerformanceOfYear::Team do
  
  describe 'calculation of single performance for one year' do
    it "returns entries" do
      la_male = Calculation::PerformanceOfYear::Team.entries(2014, :la, :male)
      expect(la_male.count).to eq 635

      expect(la_male.first.points.round).to eq 2147
      expect(la_male.first.team.id).to eq 155
      expect(la_male.first.valid_time_average).to eq 2193
      
      expect(la_male.second.points.round).to eq 2159
      expect(la_male.second.team.id).to eq 138
      expect(la_male.second.valid_time_average).to eq 2250

      la_female = Calculation::PerformanceOfYear::Team.entries(2014, :la, :female)
      expect(la_female.count).to eq 139
    end
  end
end