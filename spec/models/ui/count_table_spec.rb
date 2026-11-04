# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ui::CountTable do
  let(:view) { ApplicationController.new.view_context }
  let(:row_struct) { Struct.new(:id, :name, :team, :path) }
  let(:team_struct) { Struct.new(:shortcut) }
  let(:row) { row_struct.new(7, 'Alfred', team_struct.new('Warin'), '/people/7') }

  def build_table(rows = [row], options = nil, &)
    described_class.new(view, rows, options, &)
  end

  it 'requires a block and initializes defaults' do
    table = build_table { |_t| nil }
    expect(table.options).to eq({})
    expect(table.columns).to eq []
    expect(table.data_fields).to eq []
    expect(table.headlines).to eq []
  end

  it 'calls initialize hooks of subclasses' do
    calls = []
    subclass = Class.new(described_class) do
      define_method(:before_initialize) { calls.push(:before) }
      define_method(:after_initialize) { calls.push(:after) }
    end
    subclass.new(view, [], { class: 'x' }) { calls.push(:block) }
    expect(calls).to eq %i[before block after]
  end

  describe 'columns' do
    let(:table) do
      build_table do |t|
        t.col('Name', :name)
        t.col('Team', %i[team shortcut], th_options: { link_to: '/teams' })
        t.col('Link', :name, link_to: :path)
        t.col('Self', :name, link_to: true)
        t.col('Upcase', class: 'small') { |r| r.name.upcase }
        t.col('Helper', helper_method: :helper_value)
        t.col('Helper2', helper_method: :helper_value, helper_method_options: { suffix: '!' })
      end
    end

    before do
      allow(view).to receive(:helper_value) { |r, options = {}| "#{r.id}#{options[:suffix]}" }
      allow(view).to receive(:url_for).and_call_original
      allow(view).to receive(:url_for).with(row).and_return('/self')
    end

    it 'has headlines' do
      expect(table.headlines).to eq %w[Name Team Link Self Upcase Helper Helper2]
    end

    it 'renders content of each column' do
      expect(table.columns.map { |c| c.content(row) }).to eq [
        'Alfred',
        'Warin',
        '<a href="/people/7">Alfred</a>',
        '<a href="/self">Alfred</a>',
        'ALFRED',
        '7',
        '7!',
      ]
    end

    it 'uses options' do
      expect(table.columns[4].options).to eq(class: 'small')
      expect(table.columns[0].th_options).to eq({})
      expect(table.columns[0].th_value).to eq 'Name'
      expect(table.columns[1].th_value).to eq '<a href="/teams">Team</a>'
    end
  end

  it 'renders haml columns' do
    table = build_table { |t| t.col('Haml', haml: true, &:name) }
    allow(view).to receive(:capture_haml) { |r, &block| "captured #{block.call(r)}" }
    expect(table.columns.first.content(row)).to eq 'captured Alfred'
  end

  it 'collects row data' do
    table = build_table do |t|
      t.data(:id, &:id)
      t.data(:team) { |r| r.team.shortcut }
    end
    expect(table.row_data(row)).to eq(id: 7, team: 'Warin')
  end

  it 'calculates row classes' do
    table = build_table { |t| t.row_class { |r| r.id.odd? ? 'odd' : 'even' } }
    expect(table.row_class(row)).to eq 'odd'
    expect(build_table { |_t| nil }.row_class(row)).to be_nil
  end

  it 'stores footer' do
    footer = proc { 'footer' }
    table = build_table { |t| t.footer(class: 'foot', &footer) }
    expect(table.footer_options).to eq(class: 'foot')
    expect(table.footer_block).to eq footer
  end
end
