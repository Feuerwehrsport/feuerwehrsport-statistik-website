class Series::PersonAssessment < Series::Assessment
  def self.for(person_id)
    assessment_structs = {}
    with_person(person_id).includes(:round)
                          .order('series_rounds.name, series_rounds.year DESC, series_assessments.discipline')
                          .decorate.each do |assessment|
      row = assessment.rows.find { |r| r.entity.id == person_id }
      assessment_structs[assessment.round.name] ||= {}
      assessment_structs[assessment.round.name][assessment.round.year] ||= []
      assessment_structs[assessment.round.name][assessment.round.year].push OpenStruct.new(
        assessment: assessment,
        round: assessment.round,
        cups: assessment.round.cups,
        row: row,
      )
    end
    assessment_structs
  end
end
