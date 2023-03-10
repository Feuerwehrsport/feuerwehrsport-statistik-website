# frozen_string_literal: true

class Series::PersonAssessment < Series::Assessment
  def self.for(person_id)
    assessment_structs = {}
    with_person(person_id).includes(round: :kind)
                          .order('series_kinds.name, series_rounds.year DESC, series_assessments.discipline')
                          .decorate.each do |assessment|
      row = assessment.rows.find { |r| r.entity.id == person_id }
      assessment_structs[assessment.round.kind.name] ||= {}
      assessment_structs[assessment.round.kind.name][assessment.round.year] ||= []
      assessment_structs[assessment.round.kind.name][assessment.round.year].push OpenStruct.new(
        assessment:,
        round: assessment.round,
        cups: assessment.round.cups,
        row:,
      )
    end
    assessment_structs
  end
end
