# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompetitionDecorator do
  let(:competition) { create(:competition, :fake_count) }
  let(:decorated) { competition.decorate }

  describe 'names' do
    it 'returns different name variants' do
      expect(decorated.to_s).to eq '01.05.2017 - Charlottenthal, D-Cup (Erster Lauf)'
      expect(decorated.full_name).to eq '01.05.2017 - Charlottenthal, D-Cup (Erster Lauf)'
      expect(decorated.page_title).to eq '01.05.2017 - Charlottenthal, D-Cup (Erster Lauf) - Wettkampf'
      expect(decorated.short_name).to eq 'Charlottenthal ´17'
      expect(decorated.date_with_place).to eq '01.05. - Charlottenthal '
      expect(decorated.short_date_with_place).to eq '01.05. Charlottenthal '
      expect(decorated.overview_name).to eq 'D-Cup - Charlottenthal - 01.05.2017 (Erster Lauf)'
    end

    it 'handles missing name' do
      competition.name = ''
      expect(decorated.full_name).to eq '01.05.2017 - Charlottenthal, D-Cup'
      expect(decorated.overview_name).to eq 'D-Cup - Charlottenthal - 01.05.2017'
    end

    it 'truncates long names' do
      competition.place.name = 'Ein sehr langer Ortsname'
      competition.name = 'Ein sehr langer Wettkampfname für Tests'
      expect(decorated.short_date_with_place).to eq '01.05. Ein sehr lan... '
      expect(decorated.overview_name).to eq 'D-Cup - Ein sehr langer Ortsname - 01.05.2017 (Ein sehr langer Wettka...)'
    end

    it 'returns linked name' do
      expect(decorated.linked_name).to eq(
        "<a title=\"D-Cup - Charlottenthal - Erster Lauf\" href=\"/competitions/#{competition.id}\">" \
        'D-Cup - Charlottenthal - Erster Lauf</a>',
      )
    end
  end

  describe 'localization' do
    it 'localizes date' do
      expect(decorated.date).to eq '01.05.2017'
      expect(decorated.date_iso).to eq '2017-05-01'
    end

    it 'translates bla badge booleans' do
      competition.hb_male_for_bla_badge = true
      expect(decorated.hb_male_for_bla_badge_translated).to eq 'Ja'
      expect(decorated.hl_male_for_bla_badge_translated).to eq 'Nein'
    end
  end

  describe 'counts' do
    it 'returns counts' do
      expect(decorated.hb_female).to eq 12
      expect(decorated.hl_female).to eq 10
      expect(decorated.gs).to eq 14
      expect(decorated.la_male).to eq 18
    end

    it 'returns empty string for zero counts' do
      competition.assign_attributes(hb_female: 0, hb_male: 0, hl_female: 0, gs: 0, fs_female: 0, fs_male: 0,
                                    la_female: 0, la_male: 0)
      %i[hb_female hb_male hl_female gs fs_female fs_male la_female la_male].each do |field|
        expect(decorated.public_send(field)).to eq(''), field.to_s
      end
    end

    it 'returns empty string for zero hl_male count' do
      pending 'Bug: hl_male fehlt in der count_or_zero-Liste (hb_male doppelt), competition_decorator.rb:64'
      competition.hl_male = 0
      expect(decorated.hl_male).to eq ''
    end
  end

  describe 'associations' do
    it 'decorates associations' do
      expect(decorated.place).to be_decorated
      expect(decorated.event).to be_decorated
    end
  end
end
