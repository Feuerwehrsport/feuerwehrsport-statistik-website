require 'rails_helper'

RSpec.describe Backend::BLA::BadgesController, type: :controller, login: :admin do
  let(:person) { create(:person) }
  let(:hl_score) { create(:score, :hl, person: person) }
  let(:hb_score) { create(:score, :hb, person: person) }

  it_behaves_like 'a backend resource controller' do
    let(:resource_name) { :bla_badge }
    let(:resource_attributes) do
      {
        person_id: person.id,
        hl_score_id: hl_score.id,
        hb_score_id: hb_score.id,
        year: '2017',
        status: 'silver',
      }
    end
  end
end
