# frozen_string_literal: true
require 'rails_helper'

describe APIUser do
  it 'destroys old entries automaticly' do
    Timecop.freeze(40.days.ago) do
      create(:api_user)
    end
    expect(described_class.count).to eq 1
    create(:api_user)
    expect(described_class.count).to eq 1
  end
end
