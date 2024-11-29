# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pages' do
  let!(:score) { create(:score, :double) }

  describe 'GET dashboard' do
    it 'assigns a lot information' do
      get '/'
      expect(controller.instance_variable_get(:@last_competitions).count).to eq 1
      expect(response).to be_successful
    end
  end

  describe 'GET about' do
    it 'assigns information' do
      get '/about'
      expect(response).to be_successful
    end
  end

  describe 'GET last_competitions' do
    it 'assigns the 100 last competitions' do
      get '/last_competitions'
      expect(controller.instance_variable_get(:@last_competitions).count).to eq 1
      expect(controller.instance_variable_get(:@last_competitions).first.id).to eq score.competition_id
    end
  end

  describe 'GET firesport_overview' do
    it 'assigns nothing' do
      get '/feuerwehrsport'
      expect(response).to be_successful
    end
  end

  describe 'GET records' do
    let(:team) { build_stubbed(:team) }
    let(:nation) { build_stubbed(:nation) }
    let(:competition) { build_stubbed(:competition) }
    let(:person) { build_stubbed(:person) }

    it 'assigns nothing' do
      allow(Team).to receive(:find).and_return(team)
      allow(Nation).to receive(:find_by).and_return(nation)
      allow(Competition).to receive(:find).and_return(competition)
      allow(Person).to receive(:find).and_return(person)

      get '/records'
      expect(response).to be_successful
    end
  end
end
