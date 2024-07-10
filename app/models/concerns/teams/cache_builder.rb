# frozen_string_literal: true

module Teams::CacheBuilder
  extend ActiveSupport::Concern

  class_methods do
    def update_best_scores
      competitions = Competition.pluck(:id, :long_name).to_h
      all.find_each { |team| team.update_best_scores(competitions) }
    end
  end

  def update_best_scores(competitions)
    update_column(:best_scores,
                  female: {
                    din: {
                      pb: inject_competition(la_best_score(:din_wko, :female), competitions),
                      sb: inject_competition(la_best_score(:din_wko, :female, saison: true), competitions),
                    },
                    tgl: {
                      pb: inject_competition(la_best_score(:tgl_wko, :female), competitions),
                      sb: inject_competition(la_best_score(:tgl_wko, :female, saison: true), competitions),
                    },
                  },
                  male: {
                    din: {
                      pb: inject_competition(la_best_score(:din_wko, :male), competitions),
                      sb: inject_competition(la_best_score(:din_wko, :male, saison: true), competitions),
                    },
                    tgl: {
                      pb: inject_competition(la_best_score(:tgl_wko, :male), competitions),
                      sb: inject_competition(la_best_score(:tgl_wko, :male, saison: true), competitions),
                    },
                  })
  end

  private

  def inject_competition(score, competitions)
    return if score.nil?

    score[1] = competitions[score[1]]
    score
  end

  def la_best_score(type_key, gender, saison: false)
    type = GroupScoreType.send(type_key)
    relation = GroupScore.where(team_id: id, gender:).group_score_type(type)
    relation = relation.reorder(:time)
    relation = relation.year(Date.current.year) if saison
    relation.limit(1).pick(:time, :competition_id)
  end
end
