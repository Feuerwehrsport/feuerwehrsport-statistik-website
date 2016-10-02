class Years::Inprovement < Struct.new(:year, :discipline, :gender, :team)
  def last_year
    year - 1
  end

  def person_ids
    scores = Score.valid.send(discipline).gender(gender).group(:person_id).having("COUNT(person_id) >= 3")
    scores = scores.where(person_id: team.people) if team.present?
    scores.year(year).count.keys & scores.year(last_year).count.keys
  end

  def all
    items = {}
    Score.send(discipline).year(year).where(person: person_ids).includes(:person).includes(competition: [:place, :event]).each do |score|
      items[score.person_id] ||= Years::InprovementItem.new(score.person)
      items[score.person_id].current_scores.push score
    end
    Score.send(discipline).year(last_year).where(person: person_ids).includes(:person).includes(competition: [:place, :event]).each do |score|
      items[score.person_id] ||= Years::InprovementItem.new(score.person)
      items[score.person_id].last_scores.push score
    end
    items.values.sort
  end
end