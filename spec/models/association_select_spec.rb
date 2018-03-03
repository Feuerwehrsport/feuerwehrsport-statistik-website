require 'rails_helper'

RSpec.describe AssociationSelect, type: :model do
  let(:select) { described_class.new(Ability.new(nil, nil)) }

  describe '.competition' do
    let!(:competition) { create(:competition) }
    let(:valid_competition) { [competition.id, '01.05.2017 - Charlottenthal, D-Cup (Erster Lauf)', '01.05.2017', nil] }

    it 'returns competititons' do
      expect(select.competition(nil, nil)).to eq [valid_competition]
      expect(select.competition('char', [competition.id])).to eq [valid_competition]
      expect(select.competition('2018', nil)).to eq []
      expect(select.competition(nil, [-1])).to eq []
    end
  end

  describe '.team' do
    let!(:team) { create(:team) }
    let(:valid_team) { [team.id, 'FF Warin', 'Mecklenburg-Vorpommern', nil] }

    it 'returns teams' do
      expect(select.team(nil, nil)).to eq [valid_team]
      expect(select.team('arin', [team.id])).to eq [valid_team]
      expect(select.team('asdf', nil)).to eq []
      expect(select.team(nil, [-1])).to eq []
    end
  end

  describe '.place' do
    let!(:place) { create(:place) }
    let(:valid_place) { [place.id, 'Charlottenthal', nil, nil] }

    it 'returns places' do
      expect(select.place(nil, nil)).to eq [valid_place]
      expect(select.place('thal', [place.id])).to eq [valid_place]
      expect(select.place('asdf', nil)).to eq []
      expect(select.place(nil, [-1])).to eq []
    end
  end

  describe '.event' do
    let!(:event) { create(:event) }
    let(:valid_event) { [event.id, 'D-Cup', nil, nil] }

    it 'returns events' do
      expect(select.event(nil, nil)).to eq [valid_event]
      expect(select.event('cup', [event.id])).to eq [valid_event]
      expect(select.event('asdf', nil)).to eq []
      expect(select.event(nil, [-1])).to eq []
    end
  end

  describe '.score' do
    let!(:score) { create(:score) }
    let(:valid_score) do
      [score.id, 'Alfred Meier - 19,76', '01.05.2017 - Charlottenthal, D-Cup (Erster Lauf)', 'Hindernisbahn']
    end

    it 'returns scores' do
      expect(select.score(nil, nil)).to eq [valid_score]
      expect(select.score('meier', [score.id])).to eq [valid_score]
      expect(select.score('asdf', nil)).to eq []
      expect(select.score(nil, [-1])).to eq []
    end
  end

  describe '.person' do
    let!(:person) { create(:person) }
    let(:valid_person) { [person.id, 'Alfred Meier', 'männlich', nil] }

    it 'returns persons' do
      expect(select.person(nil, nil)).to eq [valid_person]
      expect(select.person('meier', [person.id])).to eq [valid_person]
      expect(select.person('asdf', nil)).to eq []
      expect(select.person(nil, [-1])).to eq []
    end
  end

  describe '.group_score_category' do
    let!(:group_score_category) { create(:group_score_category) }
    let(:valid_group_score_category) do
      [group_score_category.id, 'Standardwertung - 01.05.2017 - Charlottenthal, D-Cup (Erster Lauf)', 'la', nil]
    end

    it 'returns group_score_categorys' do
      expect(select.group_score_category(nil, nil)).to eq [valid_group_score_category]
      expect(select.group_score_category('thal', [group_score_category.id])).to eq [valid_group_score_category]
      expect(select.group_score_category('asdf', nil)).to eq []
      expect(select.group_score_category(nil, [-1])).to eq []
    end
  end
end
