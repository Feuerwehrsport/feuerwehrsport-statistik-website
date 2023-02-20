# frozen_string_literal: true

class BLA::BadgeGenerator
  include M3::FormObject

  def people_with_badges
    output = {}
    people_without_gold(:male, 1880, 1980).each do |person|
      output[person] = [
        badge_for(person, :gold,   1550, 1750),
        badge_for(person, :silver, 1700, 1850),
        badge_for(person, :bronze, 1850, 1950),
      ]
    end
    people_without_gold(:female, 980, 2180).each do |person|
      output[person] = [
        badge_for(person, :gold,   850, 1950),
        badge_for(person, :silver, 900, 2050),
        badge_for(person, :bronze, 950, 2150),
      ]
    end
    output
  end

  def badge_for(person, status, hl_max_time, hb_max_time)
    badge = BLA::Badge.find_or_initialize_by(person: person)
    badge.assign_attributes(status: status, hb_score: nil, hl_score: nil, hb_time: nil, hl_time: nil)
    badge.year = Date.current.year
    return if person.bla_badge && (person.bla_badge <=> badge) >= 0

    scores = person
             .scores
             .joins(:competition)
             .where(competitions: { scores_for_bla_badge: true })
             .where(Competition.arel_table[:date].gteq(Date.new(2002, 1, 1)))
             .order(Competition.arel_table[:date].asc)
    scores = yield(scores) if block_given?

    badge.hb_score = scores.low_and_high_hb.find_by(Score.arel_table[:time].lteq(hb_max_time))
    badge.hl_score = scores.hl.find_by(Score.arel_table[:time].lteq(hl_max_time))

    scores = scores.where(Competition.arel_table[:date].lteq(Date.new(2016, 1, 1)))
    badge.hb_score ||= scores.low_and_high_hb.find_by(Score.arel_table[:time].lteq(hb_max_time + 30))
    badge.hl_score ||= scores.hl.find_by(Score.arel_table[:time].lteq(hl_max_time + 30))

    badge
  end

  def people_without_gold(gender, hl_max_time, hb_max_time)
    scores = Score.select(:person_id).group(:person_id)
                  .gender(gender).joins(:competition)
                  .where(competitions: { scores_for_bla_badge: true })
                  .where(Competition.arel_table[:date].gteq(Date.new(2002, 1, 1)))
    hb_people = scores.discipline(%i[hb hw]).where(Score.arel_table[:time].lteq(hb_max_time))
    hl_people = scores.hl.where(Score.arel_table[:time].lteq(hl_max_time))
    Person.german.where(id: hb_people.where(person_id: hl_people)).reject do |person|
      person.bla_badge.try(:status) == 'gold'
    end
  end
end
