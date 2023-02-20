# frozen_string_literal: true

class TeamSpellingDecorator < AppDecorator
  decorates_association :team

  def to_s
    name
  end
end
