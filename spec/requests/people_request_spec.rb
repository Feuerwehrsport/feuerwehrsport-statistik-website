# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'People' do
  let!(:person) { create(:person) }

  describe 'GET index' do
    it 'assigns collection' do
      get '/people'
      expect(response).to be_successful
    end
  end

  describe 'GET show' do
    it 'assigns resource' do
      get "/people/#{person.id}"
      expect(response).to be_successful
      expect(controller.send(:resource)).to eq person
    end
  end

  describe 'GET show with scores and series' do
    let!(:person) { create(:person, :female) }

    it 'renders scores, teams and series participations' do
      create(:score, :hl, person:, time: 1700)
      create(:person_participation, person:)
      round = create(:series_round, kind: create(:series_kind))
      cup1 = create(:series_cup, round:)
      cup2 = create(:series_cup, round:, competition: create(:competition, date: Date.parse('2017-06-01')))
      create(:series_person_assessment, round:)
      participation = create(:series_person_participation, person:, cup: cup1)
      create(:series_person_participation, person:, cup: cup2, time: 1950, points: 14)

      get "/people/#{person.id}"
      expect(response).to be_successful
      body = response.body
      expect(body).to include('Johanna Meyer')
      expect(body).to include('FF Warin')
      expect(body).to include('D-Cup')
      expect(body).to include('2016')
      expect(controller.instance_variable_get(:@series_structs).keys).to eq ['D-Cup']
      expect(body).to include("/series/person_assessments/#{participation.person_assessment_id}")
      expect(body).to include('18,99 (15)', '19,50 (14)')
    end
  end
end
