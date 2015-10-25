class TeamDecorator < ApplicationDecorator
  delegate :to_s, to: :name
end
