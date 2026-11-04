# frozen_string_literal: true

require 'rails_helper'
require_relative 'serializer_helper'

RSpec.describe CompetitionSerializer do
  include SerializerSpecHelper

  let(:competition) { create(:competition) }
  let(:base_hash) do
    { id: competition.id, name: 'Erster Lauf', place: 'Charlottenthal', event: 'D-Cup', date: '2017-05-01',
      hint_content: nil }
  end

  it 'serializes competition' do
    expect(api_json(competition)).to eq base_hash
  end

  describe ExtendedCompetitionSerializer do
    it 'adds score counts and score type' do
      create(:score, competition:)
      create(:group_score, :double)
      competition.update!(score_type: create(:score_type))
      expect(serializer_json(described_class, competition)).to eq base_hash.merge(
        score_count: {
          hb: { female: 0, male: 1 },
          hl: { female: 0, male: 0 },
          gs: { female: 0, male: 0 },
          fs: { female: 0, male: 0 },
          la: { female: 0, male: 2 },
        },
        published_at: nil,
        score_type_id: competition.score_type_id,
        score_type: '10/8/6',
      )
    end
  end

  describe CompetitionFileSerializer do
    it 'serializes competition file' do
      file = create(:competition_file, competition:)
      expect(api_json(file)).to eq(id: file.id, competition_id: competition.id)
    end
  end

  describe EventSerializer do
    it 'serializes event' do
      expect(api_json(competition.event)).to eq(id: competition.event_id, name: 'D-Cup')
    end
  end

  describe PlaceSerializer do
    it 'serializes place' do
      expect(api_json(competition.place)).to eq(id: competition.place_id, name: 'Charlottenthal')
    end
  end

  describe NationSerializer do
    it 'serializes nation' do
      expect(api_json(create(:nation))).to eq(id: 1, name: 'Deutschland', iso: 'de')
    end
  end

  describe LinkSerializer do
    it 'serializes link with url of linkable' do
      link = create(:link, linkable: competition)
      expect(api_json(link)).to eq(
        id: link.id, label: 'Bericht auf Feuerwehrsport Team-MV', linkable_id: competition.id,
        linkable_type: 'Competition',
        url: 'http://www.feuerwehrsport-teammv.de/2012/08/24-08-2012-3-mv-steigercup-kagsdorf/',
        linkable_url: "http://test.host/competitions/#{competition.id}"
      )
    end

    it 'returns nil linkable url without linkable' do
      link = Link.new(label: 'x', url: 'http://example.com')
      expect(api_json(link)[:linkable_url]).to be_nil
    end
  end
end
