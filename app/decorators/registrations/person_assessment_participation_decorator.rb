# frozen_string_literal: true

class Registrations::PersonAssessmentParticipationDecorator < AppDecorator
  decorates_association :assessment
  decorates_association :person

  delegate :to_s, to: :person

  def self.fs_names
    %w[
      A1 A2 A3 A4
      B1 B2 B3 B4
      C1 C2 C3 C4
      D1 D2 D3 D4
    ]
  end

  def self.la_names
    [
      '1 Maschinist',
      '2 A-Länge',
      '3 Saugkorb',
      '4 B-Schlauch',
      '5 Strahlrohr links',
      '6 Verteiler',
      '7 Strahlrohr rechts',
    ]
  end

  def self.la_names_short
    [
      '1 (Ma)',
      '2 (A)',
      '3 (SK)',
      '4 (B)',
      '5 (SL)',
      '6 (V)',
      '7 (SR)',
    ]
  end

  def self.gs_names
    [
      '1 B-Schlauch',
      '2 Verteiler',
      '3 C-Schlauch',
      '4 Knoten',
      '5 D-Schlauch',
      '6 Läufer',
    ]
  end

  def self.gs_names_short
    [
      '1 (B)',
      '2 (V)',
      '3 (C)',
      '4 (Kn)',
      '5 (D)',
      '6 (Lä)',
    ]
  end

  def type
    t("assessment_types.#{assessment_type}_order", competitor_order: current_competitor_order)
  end

  def short_type
    if single_competitor? && current_competitor_order <= 0
      'E'
    else
      t("assessment_types.#{assessment_type}_short_order", competitor_order: current_competitor_order)
    end
  end

  protected

  def current_competitor_order
    if group_competitor?
      group_competitor_order
    elsif single_competitor?
      single_competitor_order
    elsif competitor?
      case assessment.discipline
      when 'fs'
        self.class.fs_names[competitor_order]
      when 'la'
        self.class.la_names_short[competitor_order]
      when 'gs'
        self.class.gs_names_short[competitor_order]
      else
        competitor_order
      end
    else
      0
    end
  end
end
