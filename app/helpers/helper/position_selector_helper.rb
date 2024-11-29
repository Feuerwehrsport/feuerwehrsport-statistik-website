# frozen_string_literal: true

module Helper::PositionSelectorHelper
  COMPETITOR_POSITION = {
    la: [
      'Maschinist',
      'A-Länge',
      'Saugkorb',
      'B-Schlauch',
      'Strahlrohr links',
      'Verteiler',
      'Strahlrohr rechts',
    ],
    gs: %w[
      B-Schlauch
      Verteiler
      C-Schlauch
      Knoten
      D-Schlauch
      Läufer
    ],
    fs: [
      { female: 'Leiterwand', male: 'Haus ' },
      { female: 'Hürde', male: 'Wand' },
      'Balken',
      'Feuer',
    ],
  }.freeze

  def competitor_position(discipline, position, gender)
    name = COMPETITOR_POSITION[discipline.to_sym][position - 1]
    name = name[gender.to_sym] if name.is_a? Hash
    name
  end

  def position_count_table(discipline, gender, rows, options = {})
    options[:class] = [options[:class], 'change-position'].flatten.compact
    count_table(rows, options) do |ct|
      yield(ct)

      ct.data(:score_id, &:id)
      ct.col('Zeit', :second_time, class: 'small col-5 time-col')

      participation_count = Discipline.participation_count(discipline)
      (1..participation_count).each do |position|
        title = competitor_position(discipline, position, gender)
        ct.col("WK#{position}", class: 'small', th_options: { title: }) do |row|
          person = row.person_participations.find { |p| p.position == position }.try(:person)
          person.nil? ? '' : person_link(person.decorate, type: :short_name)
        end
      end
    end
  end
end
