class GroupScoreTypeDecorator < ApplicationDecorator
  delegate :to_s, to: :name
end
