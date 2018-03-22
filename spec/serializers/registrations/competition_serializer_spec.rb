require 'rails_helper'

RSpec.describe Registrations::CompetitionSerializer, type: :model do
  let!(:competition) { create(:registrations_competition) }
  let!(:la) { create(:registrations_assessment, :la, competition: competition) }
  let!(:hl) { create(:registrations_assessment, competition: competition) }
  let!(:team_1) { create(:registrations_team, competition: competition) }
  let!(:team_2) { create(:registrations_team, competition: competition, assessments: [la]) }
  let!(:person_1) { create(:registrations_person, competition: competition) }
  let!(:person_2) { create(:registrations_person, competition: competition, assessments: [hl]) }
  let(:serializer) { competition.to_serializer }

  describe '.to_json' do
    it 'returns json' do
      expect(serializer.to_json).to eq({
        name: 'D-Cup', place: 'Ort', date: Time.zone.today, description: '',
        teams: [{
          id: team_1.id,
          name: 'FF Mannschaft',
          shortcut: 'Mannschaft',
          team_number: 1,
          statitics_team_id: nil,
          gender: 'male',
          assessments: [],
          tag_names: [],
          federal_state: nil,
        }, {
          id: team_2.id,
          name: 'FF Mannschaft',
          shortcut: 'Mannschaft',
          team_number: 1,
          statitics_team_id: nil,
          gender: 'male',
          assessments: [1],
          tag_names: [],
          federal_state: nil,
        }],
        assessments: [{
          discipline: 'la',
          gender: 'male',
          name: '',
          id: la.id,
        }, {
          discipline: 'hl',
          gender: 'male',
          name: '',
          id: hl.id,
        }],
        people: [{
          id: person_1.id,
          team_id: nil,
          team_name: nil,
          first_name: 'Alfred',
          last_name: 'Meier',
          statitics_person_id: nil,
          gender: 'male',
          assessment_participations: [],
          tag_names: [],
        }, {
          id: person_2.id,
          team_id: nil,
          team_name: nil,
          first_name: 'Alfred',
          last_name: 'Meier',
          statitics_person_id: nil,
          gender: 'male',
          assessment_participations: [{ assessment_id: hl.id, single_competitor_order: 0,
                                        group_competitor_order: 0, assessment_type: 'group_competitor' }],
          tag_names: [],
        }],
        person_tag_list: [], team_tag_list: []
      }.to_json)
    end
  end
end
