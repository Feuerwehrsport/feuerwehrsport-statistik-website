# frozen_string_literal: true

class TeamMemberDecorator < AppDecorator
  decorates_association :team
  decorates_association :person
end
