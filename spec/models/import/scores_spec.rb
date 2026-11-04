# frozen_string_literal: true

require 'rails_helper'

describe Import::Scores do
  let!(:team) { create(:team) }
  let!(:person) { create(:person) }
  let!(:competition) { create(:competition) }
  let(:single_discipline) { create(:single_discipline, :hb_male) }

  describe 'validation' do
    it 'requires discipline, gender and scores' do
      import = described_class.new
      expect(import).not_to be_valid
      expect(import.errors.attribute_names).to contain_exactly(:discipline, :gender, :scores)

      import = described_class.new(discipline: 'zk', gender: 'other', scores: [{}])
      expect(import).not_to be_valid
      expect(import.errors.attribute_names).to contain_exactly(:discipline, :gender)

      import = described_class.new(discipline: 'hb', gender: 'male', scores: [{}])
      expect(import).to be_valid
      expect(import.discipline).to eq :hb
    end
  end

  describe '#save!' do
    context 'with single discipline' do
      let(:import) do
        described_class.new(
          discipline: 'hb',
          gender: 'male',
          competition_id: competition.id,
          single_discipline_id: single_discipline.id,
          scores:,
        )
      end
      let(:scores) do
        [
          { person_id: person.id, team_id: team.id, team_number: '2', times: [1922, 1899] },
          { last_name: 'Meier', first_name: 'Alfred', team_id: '', team_number: '0', times: [2000] },
          { last_name: 'Neu', first_name: 'Hans', team_id: team.id, team_number: '1', times: [2100] },
        ]
      end

      it 'creates scores and missing people' do
        expect { import.save! }.to change(Score, :count).by(4).and change(Person, :count).by(1)

        new_person = Person.find_by!(last_name: 'Neu', first_name: 'Hans')
        expect(new_person.gender).to eq 'male'
        expect(new_person.nation_id).to eq 1

        expect(Score.order(:id).pluck(:person_id, :team_id, :team_number, :time, :competition_id,
                                      :single_discipline_id)).to eq [
                                        [person.id, team.id, 2, 1922, competition.id, single_discipline.id],
                                        [person.id, team.id, 2, 1899, competition.id, single_discipline.id],
                                        [person.id, nil, 0, 2000, competition.id, single_discipline.id],
                                        [new_person.id, team.id, 1, 2100, competition.id, single_discipline.id],
                                      ]
      end

      it 'finds people by spelling' do
        female = create(:person, :female)
        PersonSpelling.create!(person: female, last_name: 'Mayer', first_name: 'Joh', gender: :female)
        import.gender = 'female'
        import.scores = [{ last_name: 'Mayer', first_name: 'Joh', team_id: team.id, team_number: '1', times: [2000] }]

        expect { import.save! }.not_to change(Person, :count)
        expect(Score.last.person).to eq female
      end

      it 'rolls back on error' do
        import.scores = scores + [{ person_id: person.id, team_id: team.id, team_number: '1', times: [nil] }]
        expect { import.save! }.to raise_error(ActiveRecord::RecordInvalid)
        expect(Score.count).to eq 0
        expect(Person.count).to eq 1
      end
    end

    context 'with group discipline' do
      let(:la_category) { create(:group_score_category, competition:) }
      let(:fs_category) do
        create(:group_score_category, competition:, group_score_type: create(:group_score_type, discipline: 'fs'))
      end

      it 'creates group scores without run for la' do
        import = described_class.new(
          discipline: 'la', gender: 'female', group_score_category_id: la_category.id,
          scores: [{ team_id: team.id, team_number: '1', run: 'B', times: [2200, 2300] }]
        )
        expect { import.save! }.to change(GroupScore, :count).by(2)
        expect(GroupScore.order(:id).pluck(:team_id, :team_number, :gender, :run, :time)).to eq [
          [team.id, 1, 'female', '', 2200],
          [team.id, 1, 'female', '', 2300],
        ]
      end

      it 'creates group scores with run for fs' do
        import = described_class.new(
          discipline: 'fs', gender: 'male', group_score_category_id: fs_category.id,
          scores: [{ team_id: team.id, team_number: '2', run: 'B', times: [5000] }]
        )
        import.save!
        expect(GroupScore.last.attributes.slice('team_number', 'gender', 'run', 'time')).to eq(
          'team_number' => 2, 'gender' => 'male', 'run' => 'B', 'time' => 5000,
        )
      end
    end
  end
end
