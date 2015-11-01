class TeamDecorator < ApplicationDecorator
  delegate :to_s, to: :name

  def full_name
    name
  end
end
