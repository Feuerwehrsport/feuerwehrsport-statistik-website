class GroupScoreDecorator < ApplicationDecorator
  decorates_association :competition
  decorates_association :group_score_category
end
