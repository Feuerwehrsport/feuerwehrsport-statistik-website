# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Backend::Bla::BadgeGenerators', login: :admin do
  it_behaves_like 'a backend resource controller', only: %i[new]

  describe 'GET new with candidates' do
    let(:competition) do
      create(:competition, hl_male_for_bla_badge: true, hb_male_for_bla_badge: true)
    end
    let(:person) { create(:person) }

    it 'lists people with possible badges' do
      create(:score, :hl, person:, competition:, time: 1650)
      create(:score, :hb, person:, competition:, time: 1800)
      get '/backend/bla/badge_generator/new'
      expect(response).to be_successful
      expect(response.body).to include(%(<a href="/people/#{person.id}">Alfred Meier</a>))
      expect(response.body).to match(/class="success">\s*OK/)
      expect(response.body).to include('16,50', '18,00')
    end
  end

  context 'when sub admin', login: :sub_admin do
    it 'denies access' do
      get '/backend/bla/badge_generator/new'
      expect(response).to redirect_to('/')
    end
  end
end
