# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Series::RoundImport do
  let(:round) do
    create(:series_round, person_assessments_config_jsonb: [
             {
               key: 'female',
               disciplines: ['hb'],
               name: 'Frauen',
               calc_participations_count: 2,
               points_for_rank: [10, 8, 6],
               ranking_logic: %w[points],
             },
           ], team_assessments_config_jsonb: [
             {
               key: 'male',
               disciplines: %w[la],
               name: 'Männer',
               calc_participations_count: 2,
               points_for_rank: [20, 18],
               ranking_logic: %w[points],
             },
           ])
  end
  let(:other_round) { create(:series_round, year: 2017) }
  let(:competition) { create(:competition) }
  let(:import_data) { { results: } }
  let(:results) { [] }
  let(:import_request) { create(:import_request, import_data:) }
  let(:import) { described_class.new(round:, competition:, import_request:) }

  let(:anna) { create(:person, :female, first_name: 'Anna', last_name: 'Ahrens') }
  let(:berta) { create(:person, :female, first_name: 'Berta', last_name: 'Bauer') }
  let(:team) { create(:team, name: 'FF Warin', shortcut: 'Warin') }

  describe 'validations' do
    it 'requires competition and import request' do
      import = described_class.new(round:)
      expect(import).not_to be_valid
      expect(import.errors.attribute_names).to contain_exactly(:competition, :import_request)
      expect(import.save).to be false
    end
  end

  describe 'id assignment' do
    it 'finds round and cup by id' do
      import = described_class.new(round_id: round.id)
      expect(import.round).to eq round
    end
  end

  describe '#save' do
    let(:person_header) { %w[Platz Vorname Nachname statistik_person_id Bestzeit] }
    let(:person_rows) do
      [
        person_header,
        ['1.', 'Anna', 'Ahrens', anna.id.to_s, '17,50'],
        ['2', 'Berta', 'Bauer', '', '18.03'],
        ['3.', 'Unknown', 'Person', '', 'D'],
      ]
    end
    let(:person_result) do
      {
        discipline: 'hb',
        series_person_round_keys: ["#{round.id}-female"],
        series_team_round_keys: [],
        rows: person_rows,
      }
    end

    context 'with person result' do
      let(:results) { [person_result] }

      before { berta }

      it 'creates cup, assessment and participations' do
        cup_change = change(Series::Cup, :count).by(1)
        assessment_change = change(Series::PersonAssessment, :count).by(1)
        participation_change = change(Series::PersonParticipation, :count).by(3)
        expect { import.save }.to cup_change.and(assessment_change).and(participation_change)

        cup = Series::Cup.last
        expect(cup).to have_attributes(round:, competition:)

        assessment = Series::PersonAssessment.last
        expect(assessment).to have_attributes(round:, discipline: 'hb', key: 'female')

        # unknown people are assigned to any person until the user chooses a correct assignment
        fallback = Person.find(Person.pick(:id))
        participations = assessment.person_participations.order(:rank)
        expect(participations.map { |p| [p.person, p.rank, p.points, p.time, p.cup] }).to eq [
          [anna, 1, 10, 1750, cup],
          [berta, 2, 8, 1803, cup],
          [fallback, 3, 6, Firesport::INVALID_TIME, cup],
        ]
      end

      it 'stores assignment hints for people without id' do
        import.save
        expect(import.person_assignment_hints).to eq(
          'berta__bauer' => 'Berta Bauer',
          'unknown__person' => 'Unknown Person',
        )
        # unknown person gets any person as suggestion
        expect(import.person_assignments).to eq('berta__bauer' => berta.id, 'unknown__person' => Person.pick(:id))
      end

      it 'uses given person assignments' do
        import.person_assignments = { 'unknown__person' => berta.id.to_s }
        import.save
        expect(Series::PersonParticipation.find_by(rank: 3).person).to eq berta
      end

      it 'finds people by spelling' do
        create(:person_spelling, person: anna, first_name: 'Unknown', last_name: 'Person')
        import.save
        expect(Series::PersonParticipation.find_by(rank: 3).person).to eq anna
        expect(import.person_assignments['unknown__person']).to eq anna.id
      end

      context 'with points corrections' do
        let(:import_data) do
          {
            results:,
            person_points_corrections: [
              { round_key: "#{round.id}-female", person_id: berta.id, points_correction: -3,
                points_correction_hint: 'Strafe' },
            ],
          }
        end

        it 'stores correction' do
          import.save
          participation = Series::PersonParticipation.find_by(person: berta)
          expect(participation).to have_attributes(points: 8, points_correction: -3,
                                                   points_correction_hint: 'Strafe')
          expect(Series::PersonParticipation.find_by(person: anna, rank: 1).points_correction).to be_nil
        end
      end

      context 'when assessment exists' do
        let!(:assessment) { create(:series_person_assessment, round:, discipline: 'hb', key: 'female') }

        it 'reuses assessment' do
          expect { import.save }.not_to change(Series::PersonAssessment, :count)
          expect(assessment.person_participations.count).to eq 3
        end
      end

      context 'when round key belongs to other round' do
        let(:person_result) { super().merge(series_person_round_keys: ["#{other_round.id}-female"]) }

        it 'ignores result' do
          expect { import.save }.not_to change(Series::PersonParticipation, :count)
          expect(Series::Cup.count).to eq 1
        end
      end

      context 'when round key is unknown' do
        let(:person_result) { super().merge(series_person_round_keys: ["#{round.id}-unknown", 'invalid']) }

        it 'ignores result' do
          expect { import.save }.not_to change(Series::PersonParticipation, :count)
        end
      end

      context 'with participant without rank' do
        let(:person_rows) do
          [
            person_header,
            ['1.', 'Anna', 'Ahrens', anna.id.to_s, '17,50'],
            ['', 'Berta', 'Bauer', berta.id.to_s, 'D'],
          ]
        end

        it 'gives no points' do
          import.save
          expect(Series::PersonParticipation.find_by(person: berta).points).to eq 0
        end
      end
    end

    context 'with result without series keys' do
      let(:results) { [{ discipline: 'hb', rows: person_rows }] }

      it 'ignores result' do
        expect { import.save }.not_to change(Series::PersonParticipation, :count)
      end
    end

    context 'with result with only one row' do
      let(:results) { [person_result.merge(rows: [person_header])] }

      it 'ignores result' do
        expect { import.save }.not_to change(Series::PersonParticipation, :count)
      end
    end

    context 'with team result' do
      let(:team_rows) do
        [
          %w[Platz Mannschaft statistik_team_id statistik_team_number gender Bestzeit],
          ['1.', 'FF Warin', team.id.to_s, '1', 'male', '22,34'],
          ['2.', 'Feuerwehr Neu', '', '1', 'male', 'D'],
          ['3.', 'FF Warin II', team.id.to_s, '2', 'female', '25,00'],
        ]
      end
      let(:team_result) do
        {
          discipline: 'la',
          series_person_round_keys: [],
          series_team_round_keys: ["#{round.id}-male"],
          rows: team_rows,
        }
      end
      let(:results) { [team_result] }

      it 'creates team participations' do
        expect do
          import.save
        end.to change(Series::TeamAssessment, :count).by(1).and change(Series::TeamParticipation, :count).by(3)

        assessment = Series::TeamAssessment.last
        expect(assessment).to have_attributes(round:, discipline: 'la', key: 'male')
        expect(
          assessment.team_participations.order(:rank).map do |p|
            [p.team, p.team_number, p.team_gender, p.rank, p.points, p.time]
          end,
        ).to eq [
          [team, 1, 1, 1, 20, 2234],
          [team, 1, 1, 2, 18, Firesport::INVALID_TIME],
          [team, 2, 0, 3, 0, 2500],
        ]
      end

      it 'stores assignment hints for teams without id' do
        import.save
        expect(import.team_assignment_hints).to eq('neu' => 'Feuerwehr Neu')
        expect(import.team_assignments).to eq('neu' => team.id)
      end

      it 'finds teams by spelling' do
        other = create(:team, name: 'FF Neustadt', shortcut: 'Neustadt')
        create(:team_spelling, team: other, name: 'Neu', shortcut: 'Neu')
        import.save
        expect(Series::TeamParticipation.find_by(rank: 2).team).to eq other
      end

      context 'with group rows' do
        let(:team_result) do
          super().merge(group_rows: [
                          %w[Platz Name statistik_team_id statistik_team_number gender Summe],
                          ['1.', 'FF Warin', team.id.to_s, '1', 'female', '120,00'],
                        ])
        end

        it 'uses group rows instead of rows' do
          import.save
          expect(Series::TeamParticipation.pluck(:rank, :time, :team_gender)).to eq [[1, 12_000, 0]]
        end
      end

      context 'with points corrections' do
        let(:import_data) do
          {
            results:,
            team_points_corrections: [
              { round_key: "#{round.id}-male", team_id: team.id, team_number: 2, discipline: 'la',
                points_correction: 5, points_correction_hint: 'Bonus' },
            ],
          }
        end

        it 'stores correction' do
          import.save
          expect(Series::TeamParticipation.find_by(team_number: 2)).to have_attributes(
            points_correction: 5, points_correction_hint: 'Bonus',
          )
          expect(Series::TeamParticipation.find_by(team_number: 1, rank: 1).points_correction).to be_nil
        end
      end

      context 'when round key belongs to other round' do
        let(:team_result) { super().merge(series_team_round_keys: ["#{other_round.id}-male"]) }

        it 'ignores result' do
          expect { import.save }.not_to change(Series::TeamParticipation, :count)
        end
      end
    end
  end
end
