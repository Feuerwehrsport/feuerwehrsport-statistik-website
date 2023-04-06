# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Registrations::CompetitionSerializer, type: :model do
  let!(:competition) { create(:registrations_competition) }
  let!(:band) { create(:registrations_band, competition:) }
  let!(:la) { create(:registrations_assessment, :la, band:) }
  let!(:hl) { create(:registrations_assessment, band:) }
  let!(:team1) { create(:registrations_team, band:) }
  let!(:team2) { create(:registrations_team, band:, assessments: [la]) }
  let!(:person1) { create(:registrations_person, band:) }
  let!(:person2) { create(:registrations_person, band:, assessments: [hl]) }
  let(:serializer) { competition.to_serializer }

  describe '.to_json' do
    it 'returns json' do
      json = {
        name: 'D-Cup', place: 'Ort', date: Time.zone.today, description: '',
        bands: [
          {
            name: 'Männer',
            gender: 'male',
            teams: [{
              id: team1.id,
              name: 'FF Mannschaft',
              shortcut: 'Mannschaft',
              team_number: 1,
              statitics_team_id: nil,
              assessments: [],
              tag_names: [],
            }, {
              id: team2.id,
              name: 'FF Mannschaft',
              shortcut: 'Mannschaft',
              team_number: 1,
              statitics_team_id: nil,
              assessments: [la.id],
              tag_names: [],
            }],
            assessments: [{
              discipline: 'hl',
              name: '',
              id: hl.id,
            }, {
              discipline: 'la',
              name: '',
              id: la.id,
            }],
            people: [{
              id: person1.id,
              team_id: nil,
              team_name: nil,
              first_name: 'Alfred',
              last_name: 'Meier',
              statitics_person_id: nil,
              assessment_participations: [],
              tag_names: [],
            }, {
              id: person2.id,
              team_id: nil,
              team_name: nil,
              first_name: 'Alfred',
              last_name: 'Meier',
              statitics_person_id: nil,
              assessment_participations: [{ assessment_id: hl.id, single_competitor_order: 0, group_competitor_order: 0,
                                            competitor_order: 0, assessment_type: 'group_competitor' }],
              tag_names: [],
            }],
            person_tag_list: [], team_tag_list: []
          },
        ]
      }.to_json
      expect(serializer.to_json).to eq(json)
    end
  end
end
