class ExtendedCompetitionSerializer < CompetitionSerializer
  attributes :score_count, :published_at, :score_type_id, :score_type

  def score_type
    object.score_type.to_s
  end

  def score_count
    hash = {}
    %i[hb hl].each do |discipline|
      hash[discipline] = {}
      %i[female male].each do |gender|
        hash[discipline][gender] = object.scores.discipline(discipline).gender(gender).count
      end
    end
    %i[gs fs la].each do |discipline|
      hash[discipline] = {}
      %i[female male].each do |gender|
        hash[discipline][gender] = object.group_scores.discipline(discipline).gender(gender).count
      end
    end
    hash
  end
end
