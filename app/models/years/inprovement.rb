class Years::Inprovement < Struct.new(:year, :discipline, :gender, :team)
  def discipline_key
    discipline.is_a?(Array) ? discipline.first.to_sym : discipline.to_sym
  end

  def last_year
    year - 1
  end

  def person_ids
    scores = Score.valid.discipline(discipline).gender(gender).group(:person_id).having('COUNT(person_id) >= 3')
    scores = scores.where(person_id: team.people) if team.present?
    scores.year(year).count.keys & scores.year(last_year).count.keys
  end

  def all
    items = {}
    Score.discipline(discipline).year(year).where(person: person_ids)
         .includes(:person).includes(competition: %i[place event]).each do |score|
      items[score.person_id] ||= Years::InprovementItem.new(score.person)
      items[score.person_id].current_scores.push score
    end
    Score.discipline(discipline).year(last_year).where(person: person_ids)
         .includes(:person).includes(competition: %i[place event]).each do |score|
      items[score.person_id] ||= Years::InprovementItem.new(score.person)
      items[score.person_id].last_scores.push score
    end
    items.values.sort
  end
end
