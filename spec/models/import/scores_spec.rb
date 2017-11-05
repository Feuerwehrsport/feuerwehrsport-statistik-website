require 'rails_helper'

RSpec.describe Import::Scores, type: :model do
  let(:female_hb_slow) { described_class.new(time: 10, person: female_person, hb: 6, hl: 4) }

  pending 'sorts' do
    it '' do
    end
  end
end
