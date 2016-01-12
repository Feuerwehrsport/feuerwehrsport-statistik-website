class ExtendedCompetitionSerializer < CompetitionSerializer
  attributes :score_count, :published_at

  def score_count
    hash = {}
    [:hb, :hl].each do |discipline|
      hash[discipline] = {}
      [:female, :male].each do |gender|
        hash[discipline][gender] = object.scores.discipline(discipline).gender(gender).count
      end
    end
    [:gs, :fs, :la].each do |discipline|
      hash[discipline] = {}
      [:female, :male].each do |gender|
        hash[discipline][gender] = object.group_scores.discipline(discipline).gender(gender).count
      end
    end
    hash
  end
end
