class Series::CupDecorator < AppDecorator
  decorates_association :round
  decorates_association :competition

  delegate :to_s, to: :competition
end
