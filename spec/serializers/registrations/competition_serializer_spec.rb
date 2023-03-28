# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Registrations::CompetitionSerializer, pending: 'todo', type: :model do
  let!(:competition) { create(:registrations_competition) }
  let!(:la) { create(:registrations_assessment, :la, competition:) }
  let!(:hl) { create(:registrations_assessment, competition:) }
  let!(:team1) { create(:registrations_team, competition:) }
  let!(:team2) { create(:registrations_team, competition:, assessments: [la]) }
  let!(:person1) { create(:registrations_person, competition:) }
  let!(:person2) { create(:registrations_person, competition:, assessments: [hl]) }
  let(:serializer) { competition.to_serializer }

  describe '.to_json' do
    it 'returns json' do
      expect(serializer.to_json).to eq({
        name: 'D-Cup', place: 'Ort', date: Time.zone.today, description: '',
        teams: [{
          id: team1.id,
          name: 'FF Mannschaft',
          shortcut: 'Mannschaft',
          team_number: 1,
          statitics_team_id: nil,
          gender: 'male',
          assessments: [],
          tag_names: [],
          federal_state: nil,
        }, {
          id: team2.id,
          name: 'FF Mannschaft',
          shortcut: 'Mannschaft',
          team_number: 1,
          statitics_team_id: nil,
          gender: 'male',
          assessments: [la.id],
          tag_names: [],
          federal_state: nil,
        }],
        assessments: [{
          discipline: 'hl',
          gender: 'male',
          name: '',
          id: hl.id,
        }, {
          discipline: 'la',
          gender: 'male',
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
          gender: 'male',
          assessment_participations: [],
          tag_names: [],
        }, {
          id: person2.id,
          team_id: nil,
          team_name: nil,
          first_name: 'Alfred',
          last_name: 'Meier',
          statitics_person_id: nil,
          gender: 'male',
          assessment_participations: [{ assessment_id: hl.id, single_competitor_order: 0, group_competitor_order: 0,
                                        competitor_order: 0, assessment_type: 'group_competitor' }],
          tag_names: [],
        }],
        person_tag_list: [], team_tag_list: []
      }.to_json)
    end
  end
end
