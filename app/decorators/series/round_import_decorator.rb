class Series::RoundImportDecorator < AppDecorator
  decorates_association :round
  decorates_association :competition
end
