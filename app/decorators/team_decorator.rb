class TeamDecorator < AppDecorator
  delegate :to_s, to: :name

  def page_title
    "#{name} - Mannschaft"
  end

  def full_name
    name
  end

  def full_state
    State::ALL[state]
  end

  def human_status
    t("activerecord.attributes.team.status_#{status}")
  end
end
