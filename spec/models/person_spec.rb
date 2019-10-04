require 'rails_helper'

RSpec.describe Person, type: :model do
  let(:person) { create(:person) }
  let!(:hl) { create(:score, :hl, :double, person: person) }
  let(:competition_today) { create(:competition, date: Date.current) }
  let!(:hl_today) { create(:score, :hl, time: 4034, person: person, competition: competition_today) }

  describe '#update_best_scores' do
    context 'when person is male' do
      let!(:hb) { create(:score, :hb, time: 3012, person: person) }

      it 'calculates best scores and store it' do
        described_class.update_best_scores
        expect(person.reload.best_scores).to eq(
          'pb' => {
            'hl' => [1976, '01.05.2017 - Charlottenthal, D-Cup (Erster Lauf)'],
            'hb' => [3012, '01.05.2017 - Charlottenthal, D-Cup (Erster Lauf)'],
            'zk' => [4988, '01.05.2017 - Charlottenthal, D-Cup (Erster Lauf)'],
          },
          'sb' => {
            'hl' => [4034, '04.10.2019 - Charlottenthal, D-Cup (Erster Lauf)'],
            'hb' => nil,
            'zk' => nil,
          },
        )
      end
    end

    context 'when person is female' do
      let(:person) { create(:person, :female) }
      let!(:hw) { create(:score, :hw, time: 2001, person: person) }

      it 'calculates best scores and store it' do
        described_class.update_best_scores
        expect(person.reload.best_scores).to eq(
          'pb' => {
            'hl' => [1976, '01.05.2017 - Charlottenthal, D-Cup (Erster Lauf)'],
            'hb' => [2001, '01.05.2017 - Charlottenthal, D-Cup (Erster Lauf)'],
            'zk' => [3977, '01.05.2017 - Charlottenthal, D-Cup (Erster Lauf)'],
          },
          'sb' => {
            'hl' => [4034, '04.10.2019 - Charlottenthal, D-Cup (Erster Lauf)'],
            'hb' => nil,
            'zk' => nil,
          },
        )
      end
    end
  end
end
