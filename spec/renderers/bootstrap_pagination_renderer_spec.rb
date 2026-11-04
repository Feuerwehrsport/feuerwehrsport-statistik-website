# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BootstrapPaginationRenderer, type: :helper do
  let(:collection) { WillPaginate::Collection.new(page, 10, 100) }

  def render_pagination
    helper.will_paginate(collection, renderer: described_class, params: { controller: 'places', action: 'index' },
                                     inner_window: 2, outer_window: 0, previous_label: '<', next_label: '>')
  end

  def nodes(selector)
    Nokogiri::HTML.fragment(render_pagination).css(selector)
  end

  context 'with first page' do
    let(:page) { 1 }

    it 'renders bootstrap list with disabled prev and active page' do
      expect(nodes('ul.pagination').size).to eq 1
      expect(nodes('li.prev.disabled span').text).to eq '<'
      expect(nodes('li.active span').text).to eq '1'
      expect(nodes('li.next a').first['href']).to eq '/places?page=2'
      expect(nodes('li.disabled span').map(&:text)).to include('…')
    end
  end

  context 'with last page' do
    let(:page) { 10 }

    it 'renders disabled next and link to previous page' do
      expect(nodes('li.next.disabled span').text).to eq '>'
      expect(nodes('li.prev a').first['href']).to eq '/places?page=9'
      expect(nodes('li a[rel=prev]').map(&:text)).to eq ['<', '9']
    end
  end
end
