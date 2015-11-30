module PagesHelper
  def score_links(scores)
    scores.map do |score|
      link_to(score.second_time, score.competition, title: score.competition.event)
    end.join(", ").html_safe
  end
end