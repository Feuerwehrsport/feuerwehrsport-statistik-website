class TeamDecorator < ApplicationDecorator
  include Indexable
  index_columns :id, :name

  delegate :to_s, to: :name

  def full_name
    name
  end

  def full_state
    State::ALL[state]
  end

  def human_status
    t("activerecord.attributes.team.status#{status}")
  end
end
