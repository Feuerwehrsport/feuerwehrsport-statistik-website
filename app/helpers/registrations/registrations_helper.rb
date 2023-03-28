# frozen_string_literal: true

module Registrations::RegistrationsHelper
  def edit_participation(row, assessment, band)
    value = row.person_assessment_participations.find_by(assessment:).try(:decorate).try(:short_type)
    link = link_to(
      content_tag(:span, '', class: 'glyphicon glyphicon-pencil'),
      edit_registrations_band_person_participation_path(band, row),
      remote: true, class: 'btn btn-default btn-xs pull-right',
    )
    link = '' unless can?(:edit, row)
    safe_join([value.presence || '-', link], ' ')
  end
end
