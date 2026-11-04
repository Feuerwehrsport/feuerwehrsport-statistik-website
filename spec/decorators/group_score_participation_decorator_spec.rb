# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupScoreParticipationDecorator do
  let!(:person_participation) { create(:person_participation) }

  it 'returns second time and decorated associations' do
    decorated = GroupScoreParticipation.find_by(person_id: person_participation.person_id).decorate
    expect(decorated.second_time).to eq '22,87'
    expect(decorated.competition).to be_decorated
    expect(decorated.team.to_s).to eq 'FF Warin'
    expect(decorated.group_score_type.to_s).to eq 'WKO'
  end

  it 'returns D for invalid times' do
    expect(GroupScoreParticipation.new(time: Firesport::INVALID_TIME).decorate.second_time).to eq 'D'
  end
end
