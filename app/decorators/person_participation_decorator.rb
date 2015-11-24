class PersonParticipationDecorator < ApplicationDecorator
  include Indexable
  index_columns :id, :person, :group_score, :competition

  decorates_association :person
  decorates_association :group_score

  def to_s
    "#{person} - #{group_score}"
  end

  def competition
    group_score.competition
  end
end
