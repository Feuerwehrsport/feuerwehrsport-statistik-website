# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ui::UniqIdFinder do
  let(:finder_class) do
    Struct.new(:elements) do
      include Ui::UniqIdFinder
    end
  end
  let(:element) { Struct.new(:id) }
  let(:finder) { finder_class.new(ids.map { |id| element.new(id) }) }
  let(:ids) { [] }

  it 'parameterizes the name' do
    expect(finder.available_id('Übersicht der Wettkämpfe')).to eq 'ubersicht-der-wettkampfe'
    expect(finder.available_id(:hb)).to eq 'hb'
  end

  it 'limits the id to 50 characters' do
    expect(finder.available_id('a' * 60)).to eq 'a' * 50
  end

  context 'with existing ids' do
    let(:ids) { %w[team team-1 team-2 other] }

    it 'checks availability' do
      expect(finder.id_available?('team')).to be false
      expect(finder.id_available?('team-3')).to be true
    end

    it 'appends the next free number' do
      expect(finder.available_id('Team')).to eq 'team-3'
      expect(finder.available_id('Other')).to eq 'other-1'
      expect(finder.available_id('New')).to eq 'new'
    end
  end
end
