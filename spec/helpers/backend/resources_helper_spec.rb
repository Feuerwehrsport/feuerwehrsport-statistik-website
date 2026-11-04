# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Backend::ResourcesHelper do
  before do
    allow(helper).to receive_messages(resource_class: Place, action_name:)
    controller.request.path_parameters[:controller] = 'backend/places'
    controller.lookup_context.prefixes << 'application'
  end

  def items
    Nokogiri::HTML.fragment(helper.breadcrum).css('li').map(&:inner_html)
  end

  context 'with index action' do
    let(:action_name) { 'index' }

    it 'renders breadcrumb' do
      expect(items).to eq [
        '<a href="/backend">Administration</a>',
        '<a href="/backend/places">Wettkampforte</a>',
        'Übersicht',
      ]
    end
  end

  context 'with edit action' do
    let(:action_name) { 'edit' }

    before do
      controller.params[:id] = '12'
      controller.request.path_parameters[:id] = '12'
    end

    it 'renders breadcrumb with link to resource' do
      expect(items).to eq [
        '<a href="/backend">Administration</a>',
        '<a href="/backend/places">Wettkampforte</a>',
        '<a href="/backend/places/12">#12</a>',
        'Bearbeiten',
      ]
    end
  end

  context 'with new action' do
    let(:action_name) { 'new' }

    it 'renders breadcrumb without resource link' do
      expect(items.last(2)).to eq ['<a href="/backend/places">Wettkampforte</a>', 'Hinzufügen']
    end
  end
end
