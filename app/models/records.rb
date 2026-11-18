# frozen_string_literal: true

# World and German records from config/records.yml (records page and start page).
# People, teams, competitions and nations are loaded with one query each; missing ones (e.g. after a merge) are
# skipped, so the pages still render.
class Records
  FILE = Rails.root.join('config/records.yml')

  Holder = Struct.new(:name, :nation)
  Record = Struct.new(:discipline, :gender, :scope, :time, :note, :split, :historic, :holders, :people, :team,
                      :competition, :event) do
    def historic? = historic.present?
    def german? = scope == :german
  end
  Group = Struct.new(:key, :title, :gender, :scope, :records)

  attr_reader :updated_on, :groups

  def self.load
    new(YAML.load_file(FILE, permitted_classes: [Date]))
  end

  def initialize(data)
    @updated_on = data.fetch('updated_on')
    raw_groups = data.fetch('groups')
    entries = raw_groups.flat_map { |group| group.fetch('records') }
    @people = Person.where(id: entries.flat_map { |e| e['people'] || [] }).index_by(&:id)
    @teams = Team.where(id: entries.filter_map { |e| e['team'] }).index_by(&:id)
    @competitions = Competition.where(id: entries.filter_map { |e| e['competition'] })
                               .includes(:place, :event).index_by(&:id)
    nation_isos = entries.flat_map { |e| (e['holders'] || []).map { |h| h['nation'] } }.uniq
    @nations = Nation.where(iso: nation_isos).index_by(&:iso)
    @groups = raw_groups.map { |group| build_group(group) }
  end

  # current German record of a discipline (records under old rules are skipped)
  def german(discipline, gender)
    groups.find { |group| group.scope == :german && group.gender == gender.to_sym }
          &.records&.find { |record| record.discipline == discipline.to_sym && !record.historic? }
  end

  private

  def build_group(group)
    gender = group.fetch('gender').to_sym
    scope = group.fetch('scope').to_sym
    Group.new(key: group.fetch('key'), title: group.fetch('title'), gender:, scope:,
              records: group.fetch('records').map { |entry| build_record(entry, gender, scope) })
  end

  def build_record(entry, gender, scope)
    Record.new(
      discipline: entry.fetch('discipline').to_sym, gender:, scope:, time: entry.fetch('time'),
      note: entry['note'], split: entry['split'], historic: entry['historic'],
      holders: (entry['holders'] || []).map do |h|
        Holder.new(name: h['name'], nation: @nations[h['nation']]&.decorate)
      end,
      people: (entry['people'] || []).filter_map { |id| @people[id]&.decorate },
      team: @teams[entry['team']]&.decorate,
      competition: @competitions[entry['competition']]&.decorate,
      event: entry['event']
    )
  end
end
