# frozen_string_literal: true

module Helper::PositionSelectorHelper
  def position_count_table(discipline, gender, rows, options = {})
    options[:class] = [options[:class], 'change-position'].flatten.compact
    count_table(rows, options) do |ct|
      yield(ct)

      ct.data(:score_id, &:id)
      ct.col('Zeit', :second_time, class: 'small col-5 time-col')

      participation_count = Discipline.participation_count(discipline)
      (1..participation_count).each do |position|
        title = competitor_position(discipline, position, gender)
        ct.col("WK#{position}", class: 'small', th_options: { title: title }) do |row|
          person = row.person_participations.find { |p| p.position == position }.try(:person)
          person.nil? ? '' : person_link(person.decorate, type: :short_name)
        end
      end
    end
  end
end
