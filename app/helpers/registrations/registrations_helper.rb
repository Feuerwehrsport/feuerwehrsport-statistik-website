# frozen_string_literal: true

module Registrations::RegistrationsHelper
  def edit_participation(row, assessment, competition)
    value = row.person_assessment_participations.find_by(assessment: assessment).try(:decorate).try(:short_type)
    link = link_to(
      content_tag(:span, '', class: 'glyphicon glyphicon-pencil'),
      edit_registrations_competition_person_participation_path(competition, row),
      remote: true, class: 'btn btn-default btn-xs pull-right',
    )
    link = can?(:edit, row) ? link : ''
    safe_join([value.presence || '-', link], ' ')
  end
end
