class BLA::BadgeGenerator
  include M3::FormObject
  attr_accessor :year
  validates :year, numericality: { only_integer: true }

  def save
    valid?
  end

  def people_with_badges
    output = {}
    people_without_gold.each do |person|
      output[person] = [
        badge_for(person, :gold,   1550, 1750),
        badge_for(person, :silver, 1700, 1850),
        badge_for(person, :bronze, 1850, 1950),
      ]
    end
    output
  end

  def badge_for(person, status, hl_max_time, hb_max_time)
    badge = BLA::Badge.new(person: person, status: status)
    return if person.bla_badge && (person.bla_badge <=> badge) >= 0
    badge.year = Date.current.year

    hb_max_time += 30
    hl_max_time += 30

    scores = person
             .scores
             .joins(:competition)
             .where(competitions: { scores_for_bla_badge: true })
             .order(Competition.arel_table[:date].asc)
    hb_scores = scores.hb.where(Score.arel_table[:time].lteq(hb_max_time))
    hl_scores = scores.hl.where(Score.arel_table[:time].lteq(hl_max_time))
    badge.hb_score = hb_scores.first
    badge.hl_score = hl_scores.first
    badge
  end

  def people_without_gold
    scores = Score.select(:person_id).group(:person_id)
                  .gender(:male).joins(:competition).where(competitions: { scores_for_bla_badge: true })
    hb_people = scores.hb.where(Score.arel_table[:time].lteq(1980))
    hl_people = scores.hl.where(Score.arel_table[:time].lteq(1880))
    Person.german.where(id: hb_people.where(person_id: hl_people)).reject do |person|
      person.bla_badge.try(:status) == 'gold'
    end
  end
end
