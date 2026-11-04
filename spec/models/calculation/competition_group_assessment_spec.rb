# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Calculation::CompetitionGroupAssessment do
  let(:team) { create(:team) }
  let(:competition) { create(:competition, score_type: create(:score_type, people: 3, run: 3, score: 2)) }
  let(:assessment) { described_class.new(team, 1, competition, :male) }

  def add(time, first_name)
    score = create(:score, team:, competition:, time:, person: create(:person, first_name:))
    assessment.add_score(score)
    score
  end

  it 'delegates team id' do
    expect(assessment.team_id).to eq team.id
  end

  context 'with enough valid scores' do
    let!(:invalid) { add(Firesport::INVALID_TIME, 'Carl') }
    let!(:slow) { add(2000, 'Bernd') }
    let!(:fast) { add(1900, 'Alfred') }

    it 'sorts scores' do
      expect(assessment.scores).to eq [fast, slow, invalid]
    end

    it 'uses score count of competition score type' do
      expect(assessment.score_in_assessment).to eq [fast, slow]
      expect(assessment.score_out_assessment).to eq [invalid]
      expect(assessment.time).to eq 3900
    end

    it 'calculates with other score counts' do
      expect(assessment.score_in_assessment(1)).to eq [fast]
      expect(assessment.score_out_assessment(1)).to eq [slow, invalid]
      expect(assessment.time(1)).to eq 1900
      expect(assessment.time(3)).to eq Firesport::INVALID_TIME
      expect(assessment.time(4)).to eq Firesport::INVALID_TIME
      expect(assessment.time).to eq 3900
    end

    it 'is decoratable' do
      decorated = assessment.decorate
      expect(decorated.second_time).to eq '39,00'
      expect(decorated.second_time_by_6).to eq 'D'
      expect(decorated.score_in_assessment).to all(be_decorated)
      expect(decorated.competition).to be_decorated
    end
  end

  it 'sorts assessments by time' do
    add(2000, 'Alfred')
    add(2000, 'Bernd')
    other = described_class.new(team, 2, competition, :male)
    other.add_score(create(:score, team:, competition:, time: 1900, team_number: 2))
    other.add_score(create(:score, team:, competition:, time: Firesport::INVALID_TIME, team_number: 2,
                                   person: create(:person, first_name: 'Dieter')))

    expect([other, assessment].sort).to eq [assessment, other]
  end
end
