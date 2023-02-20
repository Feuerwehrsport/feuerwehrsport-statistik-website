# frozen_string_literal: true

class Registrations::TagsController < Registrations::BaseController
  default_actions :edit, :update, for_class: Registrations::Competition
  belongs_to Registrations::Competition, url: -> { collection_redirect_url }

  default_form do |f|
    f.inputs 'Markierungen' do
      f.input :person_tags
      f.input :team_tags
    end
    f.inputs 'Mannschaftswertung' do
      f.input :group_score
    end
  end

  protected

  def find_resource
    parent_resource
  end

  def collection_redirect_url
    url_for(parent_resource)
  end
end
