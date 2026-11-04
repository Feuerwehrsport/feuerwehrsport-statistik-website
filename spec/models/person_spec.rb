# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Person do
  let(:person) { create(:person) }
  let!(:hl) { create(:score, :hl, :double, person:) }
  let(:competition_today) { create(:competition, date: Date.current) }
  let!(:hl_today) { create(:score, :hl, time: 4034, person:, competition: competition_today) }

  describe '#update_best_scores' do
    context 'when person is male' do
      let!(:hb) { create(:score, :hb, time: 3012, person:) }

      it 'calculates best scores and store it' do
        described_class.update_best_scores
        expect(person.reload.best_scores).to eq(
          'pb' => {
            'hl' => [1976, '01.05.2017 - Charlottenthal, D-Cup (Erster Lauf)'],
            'hb' => [3012, '01.05.2017 - Charlottenthal, D-Cup (Erster Lauf)'],
            'zk' => [4988, '01.05.2017 - Charlottenthal, D-Cup (Erster Lauf)'],
          },
          'sb' => {
            'hl' => [4034, "#{I18n.l(Date.current)} - Charlottenthal, D-Cup (Erster Lauf)"],
            'hb' => nil,
            'zk' => nil,
          },
        )
      end
    end

    context 'when person is female' do
      let(:person) { create(:person, :female) }
      let!(:hw) { create(:score, :hb, time: 2001, person:) }

      it 'calculates best scores and store it' do
        described_class.update_best_scores
        expect(person.reload.best_scores).to eq(
          'pb' => {
            'hl' => [1976, '01.05.2017 - Charlottenthal, D-Cup (Erster Lauf)'],
            'hb' => [2001, '01.05.2017 - Charlottenthal, D-Cup (Erster Lauf)'],
            'zk' => [3977, '01.05.2017 - Charlottenthal, D-Cup (Erster Lauf)'],
          },
          'sb' => {
            'hl' => [4034, "#{I18n.l(Date.current)} - Charlottenthal, D-Cup (Erster Lauf)"],
            'hb' => nil,
            'zk' => nil,
          },
        )
      end
    end
  end

  describe 'scopes' do
    let!(:johanna) { create(:person, :female) }
    let!(:foreigner) { create(:person, first_name: 'Istvan', last_name: 'Nagy', nation: create(:nation, :ungarn)) }

    it 'searches by name' do
      expect(described_class.search('meier')).to eq [person]
      expect(described_class.search('Johanna')).to eq [johanna]
      expect(described_class.search_exactly('MEIER', 'alfred')).to eq [person]
      expect(described_class.search_exactly('Meier', 'Alf')).to be_empty
      expect(described_class.where_name_like('afmei')).to eq [person]
    end

    it 'searches by spelling' do
      create(:person_spelling, person: johanna, first_name: 'Hanna', last_name: 'Maier')
      expect(described_class.where_name_like('Hanna Maier')).to eq [johanna]
    end

    it 'filters by nation and gender' do
      expect(described_class.german).to contain_exactly(person, johanna)
      expect(described_class.nation(2)).to eq [foreigner]
      expect(described_class.gender(:female)).to eq [johanna]
    end

    it 'orders by name' do
      expect(described_class.index_order).to eq [person, johanna, foreigner]
      expect(described_class.filter_collection).to eq [person, johanna, foreigner]
    end

    it 'filters and orders by teams' do
      team = person.scores.first.team
      expect(described_class.team(team.id).distinct).to eq [person]
      expect(described_class.order_by_teams(Team.where(id: team.id)).first).to eq person
      expect(described_class.order_by_gender(:female).first).to eq johanna
    end

    it 'finds unused people' do
      expect(described_class.unused).to contain_exactly(johanna, foreigner)
    end
  end

  describe 'validation' do
    it 'requires last name and gender' do
      expect(described_class.new(first_name: 'X', nation: Nation.first)).not_to be_valid
    end
  end

  describe '#merge_to' do
    let(:other) { create(:person, first_name: 'Alfredo') }

    it 'raises for same person' do
      expect { person.merge_to(person) }.to raise_error(ActiveRecord::ActiveRecordError, 'same id')
    end

    it 'moves all associated records' do
      participation = create(:person_participation, person:)
      spelling = create(:person_spelling, person:)

      person.merge_to(other)

      expect(hl.reload.person).to eq other
      expect(hl_today.reload.person).to eq other
      expect(participation.reload.person).to eq other
      expect(spelling.reload.person).to eq other
    end
  end
end
