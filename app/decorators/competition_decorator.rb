class CompetitionDecorator < ApplicationDecorator
  decorates_association :place
  decorates_association :event

  def short_name
    "#{place.name} ´#{date.strftime('%y')}"
  end
end
