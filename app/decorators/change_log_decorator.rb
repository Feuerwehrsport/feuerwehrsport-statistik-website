# frozen_string_literal: true

class ChangeLogDecorator < AppDecorator
  include UrlSupport

  LINKABLE_CLASSES = [
    'AdminUser',
    'Competition',
    'Event',
    'GroupScore',
    'GroupScoreCategory',
    'GroupScoreType',
    'ImportRequest',
    'Nation',
    'Person',
    'PersonSpelling',
    'Place',
    'Score',
    'ScoreType',
    'Series::Participation',
    'Series::PersonParticipation',
    'Series::TeamParticipation',
    'Team',
  ].freeze

  delegate :link_to, to: :h

  decorates_association :admin_user
  decorates_association :api_user

  def diff_hash
    before_hash = object.content[:before_hash] || {}
    after_hash = object.content[:after_hash] || {}
    before_hash.deep_diff(after_hash)
  end

  def related_id
    before_hash = object.content[:before_hash] || {}
    after_hash = object.content[:after_hash] || {}
    before_hash[:id] || after_hash[:id]
  end

  def translated_action
    default = "#{object.model_class} #{object.action}"
    I18n.t("change_logs.#{object.model_class.underscore}.#{object.action.underscore}", default_ab: default)
  end

  def user_name
    admin_user || 'API-Benutzer'
  end

  def translated_diff_hash(*only)
    diff_sentences = diff_hash.reject { |key, _c| only.present? && !key.in?(only) }.map do |key, changes|
      "#{model_class.constantize.human_attribute_name(key)}: von »#{changes.first}« zu »#{changes.last}«"
    end.to_sentence

    "Objekt-ID: #{related_id} #{diff_sentences}"
  end

  def readable_content
    return send(model_class_readable_method) if respond_to?(model_class_readable_method)
    return translated_diff_hash unless model_class.in?(LINKABLE_CLASSES)

    default_readable_link || translated_diff_hash
  rescue NameError, ActionController::UrlGenerationError => e
    "NameError: #{e.message} #{translated_diff_hash}"
  end

  def model_class_readable_method
    :"readable_#{model_class.parameterize.underscore}"
  end

  def default_readable_link
    if action.starts_with?('create-') || action.starts_with?('update-')
      link_to(after_model.try(:change_log_to_s) || after_model, default_model_url(after_model))
    elsif action.starts_with?('destroy-')
      link_to(before_model.try(:change_log_to_s) || before_model, default_model_url(before_model))
    end
  end

  def default_model_url(model)
    model = model.object if model.decorated?
    controller = model.class.name.underscore.pluralize
    url_for(controller:, action: :show, id: model.to_param)
  rescue ActionController::UrlGenerationError
    begin
      url_for(controller: "backend/#{controller}", action: :show, id: model.to_param)
    rescue ActionController::UrlGenerationError
      url_for(controller: "backend/#{controller}", action: :index)
    end
  end

  def readable_link
    case action
    when 'create-link', 'update-link'
      h.safe_join(['Link ', link_to(after_model.label, after_model.url), ' bei ',
                   link_to(after_model.linkable, after_model.linkable)])
    when 'destroy-link'
      h.safe_join(['Link ', link_to(before_model.label, before_model.url), ' bei ',
                   link_to(before_model.linkable, before_model.linkable)])
    else
      translated_diff_hash
    end
  end

  def readable_competitionfile
    if action.in?(%w[create-competitionfile files-competitionfile])
      link_to(diff_hash[:file].second[:url], competition_url(after_model.competition_id))
    else
      default_readable_link || translated_diff_hash
    end
  end

  def readable_team
    if action == 'merge'
      h.safe_join(['Integriere ', link_to(before_model, before_model), ' in ', link_to(after_model, after_model)])
    else
      default_readable_link || translated_diff_hash
    end
  end

  def readable_person
    if action == 'merge'
      h.safe_join(['Integriere ', link_to(before_model, before_model), ' in ', link_to(after_model, after_model)])
    else
      default_readable_link || translated_diff_hash
    end
  end

  def readable_import_scores
    competition = Competition.find_by(id: diff_hash[:competition_id].last)&.decorate
    if action == 'scores-import-scores' && competition
      h.safe_join(['Füge Zeiten zu Wettkampf ', link_to(competition, competition), ' hinzu'])
    else
      translated_diff_hash
    end
  end

  def readable_changerequest
    translated_diff_hash(:done_at, :id)
  end

  def after_model
    @after_model ||= build_after_model.decorate
  end

  def before_model
    @before_model ||= build_before_model.decorate
  end
end
