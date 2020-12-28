Years::Inprovement = Struct.new(:year, :discipline, :gender, :team) do
  def discipline_key
    discipline.is_a?(Array) ? discipline.first.to_sym : discipline.to_sym
  end

  def last_year
    year - 1
  end

  def person_ids
    @person_ids || begin
      scores = Score.valid.discipline(discipline).gender(gender).group(:person_id)
      scores = scores.where(person_id: team.people) if team.present?
      year_count = year == 2020 ? 2 : 3
      last_year_count = last_year == 2020 ? 2 : 3
      year_ids = scores.having("COUNT(person_id) >= #{year_count}").year(year).count.keys
      last_year_ids = scores.having("COUNT(person_id) >= #{last_year_count}").year(last_year).count.keys
      year_ids & last_year_ids
    end
  end

  def all
    items = {}
    Score.discipline(discipline).year(year).where(person: person_ids)
         .includes(:person).includes(competition: %i[place event]).find_each do |score|
      items[score.person_id] ||= Years::InprovementItem.new(score.person, year)
      items[score.person_id].current_scores.push score
    end
    Score.discipline(discipline).year(last_year).where(person: person_ids)
         .includes(:person).includes(competition: %i[place event]).find_each do |score|
      items[score.person_id] ||= Years::InprovementItem.new(score.person, year)
      items[score.person_id].last_scores.push score
    end
    items.values.sort
  end
end
