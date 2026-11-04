# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec/matchers'

describe Caching::HtmlPreLoader do
  include WebMock::API
  include WebMock::Matchers

  let(:loader) { described_class.new }
  let!(:place) { create(:place) }
  let!(:event) { create(:event) }

  before { create(:competition, place:, event:, date: Date.new(2017, 5, 1)) }

  describe '#urls' do
    it 'contains overview and detail pages' do
      expect(loader.urls).to eq [
        'http://test.host/',
        'http://test.host/change_logs',
        'http://test.host/competitions',
        'http://test.host/people',
        'http://test.host/places',
        'http://test.host/teams',
        'http://test.host/years',
        'http://test.host/events',
        'http://test.host/best_of',
        "http://test.host/places/#{place.id}",
        'http://test.host/years/2017',
        'http://test.host/years/2017/best_performance',
        'http://test.host/years/2017/best_scores',
        "http://test.host/events/#{event.id}",
      ]
    end
  end

  describe '#perform' do
    it 'does nothing without caching' do
      expect(URI).not_to receive(:parse)
      loader.perform_now
    end

    context 'when caching is enabled' do
      before { allow(Rails.configuration).to receive(:caching).and_return(true) }
      after { WebMock.reset! }

      it 'requests all urls and ignores errors' do
        loader.urls.each { |url| stub_request(:get, url).to_return(body: 'ok') }
        stub_request(:get, 'http://test.host/people').to_return(status: 500)
        stub_request(:get, 'http://test.host/teams').to_raise(SocketError)

        expect { loader.perform_now }.not_to raise_error
        loader.urls.each { |url| expect(a_request(:get, url)).to have_been_made.once }
      end
    end
  end
end
