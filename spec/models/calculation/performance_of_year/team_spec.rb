require 'rails_helper'

describe Calculation::PerformanceOfYear::Team do
  describe 'calculation of single performance for one year' do
    let!(:group_score1) { create(:group_score, :double) }
    let!(:group_score2) { create(:group_score, :double, time: TimeInvalid::INVALID) }
    it 'returns entries' do
      la_male = Calculation::PerformanceOfYear::Team.entries(group_score1.competition.date.year, :la, :male)
      expect(la_male.count).to eq 1

      expect(la_male.first.points.round).to eq 2310
      expect(la_male.first.team.id).to eq group_score1.team_id
      expect(la_male.first.valid_time_average).to eq 2325

      la_female = Calculation::PerformanceOfYear::Team.entries(2012, :la, :female)
      expect(la_female.count).to eq 0
    end
  end
end
