class TeamMemberDecorator < ApplicationDecorator
  decorates_association :team
  decorates_association :person
end
