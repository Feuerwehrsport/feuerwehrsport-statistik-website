# frozen_string_literal: true

module Competitions::CacheBuilder
  extend ActiveSupport::Concern

  included do
    after_save :update_long_name
  end

  class_methods do
    def update_discipline_score_count
      group = GroupScore.select('COUNT(*)').where('group_score_categories.competition_id = competitions.id')
      update_all("gs = (#{group.discipline(:gs).to_sql})")

      Genderable::GENDER_KEYS.each do |gender|
        single = Score.gender(gender).select('COUNT(*)').where('competition_id = competitions.id')
        update_all("hl_#{gender} = (#{single.hl.to_sql})")
        update_all("hb_#{gender} = (#{single.low_and_high_hb.to_sql})")

        update_all("fs_#{gender} = (#{group.discipline(:fs).gender(gender).to_sql})")
        update_all("la_#{gender} = (#{group.discipline(:la).gender(gender).to_sql})")
      end

      group_score = GroupScore.joins(:group_score_category)
                              .select("CONCAT(team_id,'-',gender,'-',team_number) AS team")
                              .where('group_score_categories.competition_id = competitions.id')
      score = Score.no_finals.with_team.joins(:person)
                   .select("CONCAT(team_id,'-',gender,'-',team_number) AS team")
                   .where('competition_id = competitions.id')
      teams_count_sql = "SELECT COUNT(*) FROM ( #{group_score.to_sql} UNION #{score.to_sql} ) teams_counts"
      update_all("teams_count = (#{teams_count_sql})")

      people = Score.group(:person_id).select(:person_id).where('competition_id = competitions.id')
      person_count_sql = "SELECT COUNT(*) FROM (#{people.to_sql}) person_count"
      update_all("people_count = (#{person_count_sql})")
    end

    def update_long_names
      all.includes(:place, :event).find_each(&:update_long_name)
    end
  end

  def update_long_name
    update_column(:long_name, decorate.to_s)
  end
end
