class Series::CupDecorator < ApplicationDecorator
  decorates_association :round
  decorates_association :competition

  def to_s
    competition.to_s
  end
end