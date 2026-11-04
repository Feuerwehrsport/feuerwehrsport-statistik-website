# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bla::BadgeDecorator do
  let(:badge) { create(:bla_badge) }
  let(:decorated) { badge.decorate }

  it 'returns readable values' do
    expect(decorated.to_s).to eq 'Alfred Meier: Silber 2017'
    expect(decorated.status).to eq 'Silber'
    expect(decorated.second_hl_time).to eq '19,76'
    expect(decorated.second_hb_time).to eq '19,76'
    expect(decorated.person).to be_decorated
    expect(decorated.hl_score).to be_decorated
    expect(decorated.hb_score).to be_decorated
  end

  it 'returns current times of faster scores' do
    expect(decorated.second_current_hl_time).to eq 'D'
    create(:score, :hl, person: badge.person, time: 1500,
                        competition: create(:competition, hl_male_for_bla_badge: true))
    expect(Bla::Badge.find(badge.id).decorate.second_current_hl_time).to eq '15,00'
  end
end
