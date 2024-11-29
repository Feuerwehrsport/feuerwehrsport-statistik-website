# frozen_string_literal: true

Years::Inprovement = Struct.new(:year, :single_discipline, :gender, :team) do
  delegate :blank?, to: :person_ids

  def last_year
    year - 1
  end

  def person_ids
    @person_ids || begin
      scores = Score.valid.where(single_discipline:).gender(gender).group(:person_id)
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
    Score.where(single_discipline:).year(year).where(person: person_ids)
         .includes(:person).includes(competition: %i[place event]).each do |score|
      items[score.person_id] ||= Years::InprovementItem.new(score.person, year)
      items[score.person_id].current_scores.push score
    end
    Score.where(single_discipline:).year(last_year).where(person: person_ids)
         .includes(:person).includes(competition: %i[place event]).each do |score|
      items[score.person_id] ||= Years::InprovementItem.new(score.person, year)
      items[score.person_id].last_scores.push score
    end
    items.values.sort
  end
end
