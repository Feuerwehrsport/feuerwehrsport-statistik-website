# frozen_string_literal: true

class ChangeRequestDecorator < AppDecorator
  HEADLINES = {
    'competition-change-name' => 'Wettkampf - Name',
    'competition-add-hint' => 'Wettkampf - Hinweis',
    'competition-file-error' => 'Wettkampf - Fehlerhafte Datei',
    'person-correction' => 'Person - Korrektur',
    'person-merge' => 'Person - Zusammenführen',
    'person-other' => 'Person - Freitext',
    'person-change-nation' => 'Person - Nation ändern',
    'team-correction' => 'Mannschaft - Korrektur',
    'team-merge' => 'Mannschaft - Zusammenführen',
    'team-logo' => 'Mannschaft - Logo',
    'team-other' => 'Mannschaft - Freitext',
    'report-link' => 'Link - Meldung',
  }.freeze

  decorates_association :admin_user
  decorates_association :api_user
  decorates_association :user

  def key
    content[:key].to_s
  end

  def data
    content[:data] || {}
  end

  def headline
    HEADLINES[key] || key
  end
end
