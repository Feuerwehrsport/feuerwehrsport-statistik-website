# frozen_string_literal: true

require 'rails_helper'

describe NumberedTeamNames do
  let(:helper) { Class.new { include NumberedTeamNames }.new }
  let!(:team) { create(:team) }
  let!(:person) { create(:person) }
  let!(:competition) { create(:competition) }

  def name_for(score, options = {})
    helper.numbered_team_name(score, options)
  end

  it 'returns empty string without team' do
    expect(name_for(build(:score, team: nil))).to eq ''
  end

  it 'marks single and out of competition starts' do
    expect(name_for(build(:score, team_number: 0))).to eq 'Warin E'
    expect(name_for(build(:score, team_number: -1))).to eq 'Warin F'
    expect(name_for(build(:score, team_number: -4))).to eq 'Warin F'
    expect(name_for(build(:score, team_number: -5))).to eq 'Warin A'
  end

  context 'with single scores' do
    let!(:first_score) { create(:score, team_number: 1) }

    it 'adds team number only if team has multiple numbers in competition' do
      expect(name_for(first_score)).to eq 'Warin'

      second_score = create(:score, team_number: 2)
      expect(name_for(first_score)).to eq 'Warin 1'
      expect(name_for(second_score)).to eq 'Warin 2'
    end

    it 'separates genders' do
      female = create(:person, :female)
      create(:score, team_number: 2, person: female)
      create(:score, team_number: 3, person: female)
      expect(name_for(first_score)).to eq 'Warin'
      expect(name_for(first_score, gender: :female)).to eq 'Warin 1'
    end

    it 'uses given competition and team' do
      other_competition = create(:competition, name: 'Anderer')
      create(:score, team_number: 2, competition: other_competition)
      create(:score, team_number: 3, competition: other_competition)

      expect(name_for(first_score)).to eq 'Warin'
      expect(name_for(first_score, competition_id: other_competition.id)).to eq 'Warin 1'
      expect(name_for(first_score, competition_id: [competition.id, other_competition.id])).to eq 'Warin 1'
    end
  end

  context 'with group scores' do
    let!(:group_score) { create(:group_score, team_number: 1, run: 'B') }

    it 'adds number and run' do
      expect(name_for(group_score)).to eq 'Warin B'

      create(:group_score, team_number: 2)
      expect(name_for(group_score)).to eq 'Warin 1 B'
    end
  end

  describe CompetitionTeamNumber do
    it 'filters by gender' do
      create(:score, team_number: 1)
      create(:score, team_number: 0)
      create(:group_score, team_number: 2, gender: :female)

      expect(described_class.gender(:male).pluck(:team_number)).to eq [1]
      expect(described_class.gender('male').pluck(:team_number)).to eq [1]
      expect(described_class.gender(1).pluck(:team_number)).to eq [1]
      expect(described_class.gender(:female).pluck(:team_number)).to eq [2]
      expect(described_class.gender('female').pluck(:team_number)).to eq [2]
      expect(described_class.gender(0).pluck(:team_number)).to eq [2]
      expect(described_class.gender(nil)).to be_empty
      expect(described_class.take.team).to eq team
      expect(described_class.take.competition).to eq competition
    end
  end
end
