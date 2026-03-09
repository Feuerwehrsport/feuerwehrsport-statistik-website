# frozen_string_literal: true

class Backend::Series::RoundsController < Backend::BackendController
  backend_actions
  member_actions :import, :show, :edit, :destroy

  default_form do |f|
    f.association :kind
    f.input :year
    f.input :official
    f.input :full_cup_count
    f.input :team_assessments_config_jsonb_text, as: :text
    f.input :person_assessments_config_jsonb_text, as: :text
  end

  default_index do |t|
    t.col(:kind, sortable: false)
    t.col(:year)
    t.col(:official, &:official_translated)
    t.col(:full_cup_count)
  end

  def show
    super
    @person_assessments = Series::PersonAssessment.where(round: resource).decorate.select { |pa| pa.config.present? }
    @team_assessments_exists = Series::TeamAssessment.where(round: resource).present?
  end
end
