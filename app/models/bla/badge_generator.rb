# frozen_string_literal: true

class Bla::BadgeGenerator
  include M3::FormObject

  def people_with_badges
    output = {}
    # people_without_gold(:male, 11_880, 19_180).each do |person|
    #   output[person] = [
    #     badge_for(person, :gold,   1580, 1780),
    #     badge_for(person, :silver, 1730, 1880),
    #     badge_for(person, :bronze, 1880, 1980),
    #   ]
    # end
    people_without_gold(:female, 11_950, 12_150).each do |person|
      output[person] = [
        badge_for(person, :gold,   900, 1900),
        badge_for(person, :silver, 950, 2000),
        badge_for(person, :bronze, 1000, 2100),
      ]
    end
    output
  end

  def badge_for(person, status, hl_max_time, hb_max_time)
    badge = Bla::Badge.find_or_initialize_by(person:)
    badge.assign_attributes(status:, hb_score: nil, hl_score: nil, hb_time: nil, hl_time: nil)
    badge.year = Date.current.year
    # return if person.bla_badge && (person.bla_badge <=> badge) >= 0

    scores = person
             .scores
             .joins(:competition)
             .where(Competition.arel_table[:date].gteq(Date.new(2002, 1, 1)))
             .order(Competition.arel_table[:date].asc)
    scores = yield(scores) if block_given?

    badge.hb_score = scores.low_and_high_hb
                           .where(competitions: { "hb_#{person.gender}_for_bla_badge": true })
                           .where(Competition.arel_table[:date].gteq(Date.new(2017, 1, 1)))
                           .find_by(Score.arel_table[:time].lteq(hb_max_time))
    badge.hl_score = scores.hl
                           .where(competitions: { "hl_#{person.gender}_for_bla_badge": true })
                           .where(Competition.arel_table[:date].gteq(Date.new(2017, 1, 1)))
                           .find_by(Score.arel_table[:time].lteq(hl_max_time))

    # scores = scores.where(Competition.arel_table[:date].lteq(Date.new(2017, 1, 1)))
    # badge.hb_score ||= scores.low_and_high_hb.where(competitions: { "hb_#{person.gender}_for_bla_badge": true })
    #                          .find_by(Score.arel_table[:time].lteq(hb_max_time + 30))
    # badge.hl_score ||= scores.hl.where(competitions: { "hl_#{person.gender}_for_bla_badge": true })
    #                          .find_by(Score.arel_table[:time].lteq(hl_max_time + 30))

    if person.ignore_bla_untill_year.present? &&
       ([badge.hb_score&.competition&.year, badge.hl_score&.competition&.year, 0].compact.max <=
         person.ignore_bla_untill_year)
      badge.hl_score = nil
      badge.hb_score = nil
    end

    badge
  end

  def people_without_gold(gender, hl_max_time, hb_max_time)
    scores = Score.select(:person_id).group(:person_id)
                  .gender(gender).joins(:competition)
                  .where(Competition.arel_table[:date].gteq(Date.new(2017, 1, 1)))
    hb_people = scores.discipline(%i[hb hw]).where(Score.arel_table[:time].lteq(hb_max_time))
                      .where(competitions: { "hb_#{gender}_for_bla_badge": true })
    hl_people = scores.hl.where(Score.arel_table[:time].lteq(hl_max_time))
                      .where(competitions: { "hl_#{gender}_for_bla_badge": true })
    Person.german.where(id: hb_people.where(person_id: hl_people))
  end
end
