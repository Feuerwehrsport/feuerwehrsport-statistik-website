class ChangeLogDecorator < AppDecorator
  decorates_association :admin_user
  decorates_association :api_user

  def diff_hash
    before_hash = object.content[:before_hash] || {}
    after_hash = object.content[:after_hash] || {}
    before_hash.deep_diff(after_hash)
  end

  def translated_action
    default = "#{object.model_class} #{object.log_action || object.action_name}"
    I18n.t("change_logs.#{object.model_class.underscore.tr('/', '_')}.#{(object.log_action || object.action_name).underscore}", defaults: default)
  end

  def user_name
    admin_user || 'API-Benutzer'
  end

  def translated_diff_hash
    diff_hash.map do |key, changes|
      "#{Team.human_attribute_name(key)}: von »#{changes.first}« zu »#{changes.last}«"
    end
  end

  def readable_content
    if model_class == 'Link' && log_action == 'add-link'
      link = build_after_model.decorate
      "Link #{link_to(link.label, link.url)} bei #{link_to(link.linkable, link.linkable)}".html_safe
    elsif model_class == 'News' && object.action_name == 'create'
      news = build_after_model.decorate
      link_to(news, news_path(news))
    elsif model_class == 'Team' && log_action == 'update-state'
      before = State::ALL[diff_hash[:state].first.to_s]
      after = State::ALL[diff_hash[:state].last.to_s]
      team = build_after_model.decorate
      "Land der Mannschaft #{link_to(team, team_path(team))} von »#{before}« zu »#{after}«".html_safe
    elsif model_class == 'Team' && log_action.in?(['add-team', 'update-geo-position'])
      team = build_after_model.decorate
      link_to(team, team_path(team))
    elsif model_class == 'Competition' && log_action.in?(['add-competition', 'create'])
      competition = build_after_model.decorate
      link_to(competition, competition_path(competition))
    elsif model_class == 'Appointment' && log_action.in?(['add-appointment', 'create'])
      appointment = build_after_model.decorate
      link_to("#{appointment.dated_at} - #{appointment.place}", appointment_path(appointment))
    else
      translated_diff_hash
    end
  rescue NameError
    translated_diff_hash
  end
end
