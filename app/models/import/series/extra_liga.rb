class Import::Series::ExtraLiga < Import::Series::Base

  protected

  def assessment_disciplines
    {
      person: { hb: [""], hl: [""] },
      team: {},
      group: {},
    }
  end

  def points
    {
      person: 0,
    }
  end

  def configure_assessments
    [:female, :male].each do |gender|
      person_ids = competition.scores.gender(gender).pluck(:person_id).uniq
      people = Person.where(id: person_ids).order(:last_name, :first_name).decorate.map do |person|
        [person.id.to_s, person.full_name, true]
      end
      add_assessment_config(gender, people)
    end
  end

  def exclude_scores(scores, assessment)
    selected_people = find_assessment_config(assessment.gender).selected_entities.map do |key, name, selected|
      key
    end
    scores.select { |score| score.person_id.to_s.in?(selected_people) }
  end
  
  def create_participations(assessment, cup, scores, points)
    rank = 1
    scores.each do |score|
      points = score.time
      points = 9999 if score.time == TimeInvalid::INVALID
      hash = {
        assessment: assessment, 
        cup: cup, 
        time: score.time, 
        points: , 
        rank: rank
      }
      ::Series::PersonParticipation.create!(hash.merge(person: score.person))
      rank += 1
    end
  end
end
