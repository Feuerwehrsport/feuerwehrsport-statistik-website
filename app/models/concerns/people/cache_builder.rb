# frozen_string_literal: true

module People::CacheBuilder
  extend ActiveSupport::Concern

  class_methods do
    def update_score_count
      update_all("hb_count = (#{Score.select('COUNT(*)').hb.where('person_id = people.id').to_sql})")
      update_all("hl_count = (#{Score.select('COUNT(*)').hl.where('person_id = people.id').to_sql})")
      update_all("la_count = (#{GroupScoreParticipation.la.select('COUNT(*)').where('person_id = people.id').to_sql})")
      update_all("fs_count = (#{GroupScoreParticipation.fs.select('COUNT(*)').where('person_id = people.id').to_sql})")
      update_all("gs_count = (#{GroupScoreParticipation.gs.select('COUNT(*)').where('person_id = people.id').to_sql})")
    end

    def update_best_scores
      competitions = Competition.pluck(:id, :long_name).to_h
      all.each { |person| person.update_best_scores(competitions) }
    end
  end

  def update_best_scores(competitions)
    update_column(:best_scores,
                  pb: {
                    hl: inject_competition(hl_best_score, competitions),
                    hb: inject_competition(hb_best_score, competitions),
                    zk: inject_competition(zk_best_score, competitions),
                  },
                  sb: {
                    hl: inject_competition(hl_saison_best_score, competitions),
                    hb: inject_competition(hb_saison_best_score, competitions),
                    zk: inject_competition(zk_saison_best_score, competitions),
                  })
  end

  private

  def inject_competition(score, competitions)
    return if score.nil?

    score[1] = competitions[score[1]]
    score
  end

  def best_score_relation(relation, saison: false)
    relation = relation.reorder(:time)
    relation = relation.year(Date.current.year) if saison
    relation.limit(1).pick(:time, :competition_id)
  end

  def hl_best_score
    @hl_best_score ||= best_score_relation(scores.hl)
  end

  def hb_best_score
    @hb_best_score ||= best_score_relation(scores.hb)
  end

  def zk_best_score
    @zk_best_score ||= best_score_relation(score_double_events)
  end

  def hl_saison_best_score
    @hl_saison_best_score ||= best_score_relation(scores.hl, saison: true)
  end

  def hb_saison_best_score
    @hb_saison_best_score ||= best_score_relation(scores.hb, saison: true)
  end

  def zk_saison_best_score
    @zk_saison_best_score ||= best_score_relation(score_double_events, saison: true)
  end
end
